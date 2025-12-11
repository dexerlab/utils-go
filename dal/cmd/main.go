package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/realcaishen/utils-go/dal/model"
	"github.com/shopspring/decimal"
	"gorm.io/driver/mysql"
	"gorm.io/gen"
	"gorm.io/gorm"
)

func main() {
	// Connect to your database
	dsn := "root:@tcp(localhost:3306)/db_cs" // Example: "user:password@tcp(localhost:3306)/dbname"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect to the database: %v", err)
	}

	// Set up the generator
	g := gen.NewGenerator(gen.Config{
		OutPath:      "../query",                                    // Path where the generated files will be stored
		ModelPkgPath: "../model",                                    // Path where the model structs will be saved
		Mode:         gen.WithDefaultQuery | gen.WithQueryInterface, // Generate QueryInterface (optional)
		//FieldWithIndexTag: true,
		FieldWithTypeTag: true,
	})
	dataMap := map[string]func(detailType gorm.ColumnType) (dataType string){
		"decimal": func(detailType gorm.ColumnType) (dataType string) { return "decimal.Decimal" }, // 金额类型全部转换为第三方库,github.com/shopspring/decimal
	}

	g.WithDataTypeMap(dataMap)
	g.WithImportPkgPath("github.com/shopspring/decimal")
	// Specify the database connection
	g.UseDB(db)

	// Generate code for a specific table (e.g., "token_info" table)
	g.ApplyBasic(g.GenerateAllTable()...)

	// Optionally generate other helper methods like "crud" methods
	// g.GenerateCrud("token_info")

	// Run the code generation
	g.Execute()

	fmt.Println("Code generation complete!")

	token := model.TTokenInfo{
		ID:              1,
		InsertTimestamp: time.Now(),
		UpdateTimestamp: time.Now(),
		TokenName:       "Bitcoin",
		ChainName:       "Bitcoin",
		TokenAddress:    "abc123",
		Decimals:        8,
		FullName:        "Bitcoin",
		TotalSupply:     decimal.NewFromFloat(21000000.0),

		Icon: "bitcoin-icon",
	}

	// Serialize the object to JSON
	data, err := json.Marshal(token)
	if err != nil {
		fmt.Println("Error marshaling object:", err)
		return
	}

	// Output the JSON
	fmt.Println(string(data))
}

// 用法:
// 	// 设置默认DB对象
// 	gen.SetDefault(dal.DB)

// 	// 创建
// 	b1 := model.Book{
// 		Title:       "《七米的Go语言之路》",
// 		Author:      "七米",
// 		PublishDate: time.Date(2023, 11, 15, 0, 0, 0, 0, time.UTC),
// 		Price:       100,
// 	}
// 	err := gen.Book.WithContext(context.Background()).Create(&b1)
// 	if err != nil {
// 		fmt.Printf("create book fail, err:%v\n", err)
// 		return
// 	}

// 	// 更新
// 	ret, err := gen.Book.WithContext(context.Background()).
// 		Where(gen.Book.ID.Eq(1)).
// 		Update(gen.Book.Price, 200)
// 	if err != nil {
// 		fmt.Printf("update book fail, err:%v\n", err)
// 		return
// 	}
// 	fmt.Printf("RowsAffected:%v\n", ret.RowsAffected)

// 	// 查询
// 	book, err := gen.Book.WithContext(context.Background()).First()
// 	// 也可以使用全局Q对象查询
// 	//book, err := gen.Q.Book.WithContext(context.Background()).First()
// 	if err != nil {
// 		fmt.Printf("gen book fail, err:%v\n", err)
// 		return
// 	}
// 	fmt.Printf("book:%v\n", book)

// 	// 删除
// 	ret, err = gen.Book.WithContext(context.Background()).Where(gen.Book.ID.Eq(1)).Delete()
// 	if err != nil {
// 		fmt.Printf("delete book fail, err:%v\n", err)
// 		return
// 	}
// 	fmt.Printf("RowsAffected:%v\n", ret.RowsAffected)

// Gen 为动态条件 SQL 支持提供了一些约定语法，分为三个方面：

// 返回结果
// 模板占位符
// 模板表达式
// 返回结果
// 占位符	含义
// gen.T	用于返回数据的结构体，会根据生成结构体或者数据库表结构自动生成
// gen.M	表示map[string]interface{},用于返回数据
// gen.RowsAffected	用于执行SQL进行更新或删除时候,用于返回影响行数
// error	返回错误（如果有）
// 示例
// // dal/model/querier.go

// package model

// import "gorm.io/gen"

// // 通过添加注释生成自定义方法

// type Querier interface {
// 	// SELECT * FROM @@table WHERE id=@id
// 	GetByID(id int) (gen.T, error) // 返回结构体和error

// 	// GetByIDReturnMap 根据ID查询返回map
// 	//
// 	// SELECT * FROM @@table WHERE id=@id
// 	GetByIDReturnMap(id int) (gen.M, error) // 返回 map 和 error

// 	// SELECT * FROM @@table WHERE author=@author
// 	GetBooksByAuthor(author string) ([]*gen.T, error) // 返回数据切片和 error
// }
// 在Gen配置处（cmd/gen/generate.go）添加自定义方法绑定关系。

// // 通过ApplyInterface添加为book表添加自定义方法
// g.ApplyInterface(func(model.Querier) {}, g.GenerateModel("book"))
// 重新生成代码后，即可使用自定义方法。

// // 使用自定义的GetBooksByAuthor方法
// rets, err := query.Book.WithContext(context.Background()).GetBooksByAuthor("七米")
// if err != nil {
// 	fmt.Printf("GetBooksByAuthor fail, err:%v\n", err)
// 	return
// }
// for i, b := range rets {
// 	fmt.Printf("%d:%v\n", i, b)
// }
// 模板占位符
// 名称	描述
// @@table	转义和引用表名
// @@<name>	从参数中转义并引用表/列名
// @<name>	参数中的SQL查询参数
// 示例

// // Filter 自定义Filter接口
// type Filter interface {
//   // SELECT * FROM @@table WHERE @@column=@value
//   FilterWithColumn(column string, value string) (gen.T, error)
// }

// // 为`Book`添加 `Filter`接口
// g.ApplyInterface(func(model.Filter) {}, g.GenerateModel("book"))
// 模板表达式
// Gen 为动态条件 SQL 提供了强大的表达式支持，目前支持以下表达式:

// if/else
// where
// set
// for
// 示例

// // Searcher 自定义接口
// type Searcher interface {
// 	// Search 根据指定条件查询书籍
// 	//
// 	// SELECT * FROM book
// 	// WHERE publish_date is not null
// 	// {{if book != nil}}
// 	//   {{if book.ID > 0}}
// 	//     AND id = @book.ID
// 	//   {{else if book.Author != ""}}
// 	//     AND author=@book.Author
// 	//   {{end}}
// 	// {{end}}
// 	Search(book *gen.T) ([]*gen.T, error)
// }

// // 通过ApplyInterface添加为book表添加Searcher接口
// g.ApplyInterface(func(model.Searcher) {}, g.GenerateModel("book"))
// 重新生成代码后，即可直接使用自定义的Search方法进行查询。

// b := &model.Book{Author: "Q1mi"}
// rets, err = query.Book.WithContext(context.Background()).Search(b)
// if err != nil {
// 	fmt.Printf("Search fail, err:%v\n", err)
// 	return
// }
// for i, b := range rets {
// 	fmt.Printf("%d:%v\n", i, b)
// }

// 方法模板
// 当从数据库生成结构体时，还可以为它们生成事先配置的模板方法，例如：

// type CommonMethod struct {
//     ID   int32
//     Name *string
// }

// func (m *CommonMethod) IsEmpty() bool {
//     if m == nil {
//         return true
//     }
//     return m.ID == 0
// }

// func (m *CommonMethod) GetName() string {
//     if m == nil || m.Name == nil {
//         return ""
//     }
//     return *m.Name
// }

// // 当生成 `People` 结构体时添加 IsEmpty 方法
// g.GenerateModel("people", gen.WithMethod(CommonMethod{}.IsEmpty))

// // 生成`User`结构体时添加 `CommonMethod` 的所有方法
// g.GenerateModel("user", gen.WithMethod(CommonMethod{}))

// Gen支持根据GORM约定依据数据库生成结构体，在之前的示例中我们已经使用过类似的代码。

// // 根据`users`表生成对应结构体`User`
// g.GenerateModel("users")

// // 基于`users`表生成名为`Employee`的结构体
// g.GenerateModelAs("users", "Employee")

// // 在生成结构体时还可指定额外的生成选项
// // gen.FieldIgnore("address")：忽略 address 字段
// // gen.FieldType("id", "int64")：id字段使用 int64 类型
// g.GenerateModel("users", gen.FieldIgnore("address"), gen.FieldType("id", "int64"))

// // 为连接的数据库中的所有表生成对应结构体
// g.GenerateAllTable()
