-- questdb
CREATE TABLE t_trade (
  ts TIMESTAMP,
  -- Time of the trade
  pool_id BIGINT,
  -- 'long' does not exist in Postgres, use BIGINT
  is_buy BOOLEAN,
  -- Buy (true), Sell (false)
  priceu DOUBLE PRECISION,
  price01 DOUBLE PRECISION,
  -- priceu in u
  amount0 DOUBLE PRECISION,
  amount1 DOUBLE PRECISION,
  amountu DOUBLE PRECISION -- amountu in u
) timestamp(ts) PARTITION BY HOUR TTL 10 DAY WAL DEDUP UPSERT KEYS(ts, pool_id);

/*
SELECT 'DROP MATERIALIZED VIEW ' || table_name || ';' 
FROM tables() 
WHERE table_name LIKE 't_kline_%';
 concat('DROP TABLE ', table_name, ';') 
 */

-- 5 Minute
CREATE MATERIALIZED VIEW t_kline_5m AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 5m ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY DAY;

-- 15 Minute
CREATE MATERIALIZED VIEW t_kline_15m AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 15m ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY DAY;

-- 30 Minute
CREATE MATERIALIZED VIEW t_kline_30m AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 30m ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY DAY;

-- 1 Hour
CREATE MATERIALIZED VIEW t_kline_1h AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 1h ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY WEEK;

-- 4 Hour
CREATE MATERIALIZED VIEW t_kline_4h AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 4h ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY WEEK;

-- 12 Hour
CREATE MATERIALIZED VIEW t_kline_12h AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 12h ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY MONTH;

-- 1 Day
CREATE MATERIALIZED VIEW t_kline_1d AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 1d ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY MONTH;

-- 1 Week
CREATE MATERIALIZED VIEW t_kline_1w AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 1w ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY YEAR;

-- 1 Month
CREATE MATERIALIZED VIEW t_kline_1mo AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 1M ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY YEAR;

-- 1 Year
CREATE MATERIALIZED VIEW t_kline_1y AS (
  SELECT
    ts,
    pool_id,
    first(priceu) openu,
    max(priceu) highu,
    min(priceu) lowu,
    last(priceu) closeu,
    first(price01) open01,
    max(price01) high01,
    min(price01) low01,
    last(price01) close01,
    sum(amount0 * is_buy :: int) buy0,
    sum(amount0 * (NOT is_buy) :: int) sell0,
    sum(amount1 * is_buy :: int) buy1,
    sum(amount1 * (NOT is_buy) :: int) sell1,
    sum(amountu * is_buy :: int) buyu,
    sum(amountu * (NOT is_buy) :: int) sellu,
    sum(is_buy :: int) AS buys,
    sum((NOT is_buy) :: int) AS sells
  FROM
    t_trade SAMPLE BY 1y ALIGN TO CALENDAR
) timestamp(ts) PARTITION BY YEAR;

-- ***********************
-- postgresql for questdb
-- ***********************
CREATE TABLE t_trade (
  ts TIMESTAMP NOT NULL,
  -- Time of the trade
  pool_id BIGINT NOT NULL,
  -- 'long' does not exist in Postgres, use BIGINT
  is_buy BOOLEAN NOT NULL,
  -- Buy (true), Sell (false)
  priceu DOUBLE PRECISION NOT NULL,
  price01 DOUBLE PRECISION NOT NULL,
  amount0 DOUBLE PRECISION NOT NULL,
  amount1 DOUBLE PRECISION NOT NULL,
  amountu DOUBLE PRECISION NOT NULL
);

/*
SELECT 'DROP TABLE ' || string_agg(quote_ident(tablename), ', ') || ' CASCADE;'
FROM pg_tables
WHERE tablename LIKE 't_kline_%'
AND schemaname = 'public';
 */

CREATE TABLE t_kline_5m (
  ts TIMESTAMP NOT NULL,
  pool_id BIGINT NOT NULL,
  openu DOUBLE PRECISION NOT NULL,
  highu DOUBLE PRECISION NOT NULL,
  lowu DOUBLE PRECISION NOT NULL,
  closeu DOUBLE PRECISION NOT NULL,
  open01 DOUBLE PRECISION NOT NULL,
  high01 DOUBLE PRECISION NOT NULL,
  low01 DOUBLE PRECISION NOT NULL,
  close01 DOUBLE PRECISION NOT NULL,
  buy0 DOUBLE PRECISION NOT NULL,
  sell0 DOUBLE PRECISION NOT NULL,
  buy1 DOUBLE PRECISION NOT NULL,
  sell1 DOUBLE PRECISION NOT NULL,
  buyu DOUBLE PRECISION NOT NULL,
  sellu DOUBLE PRECISION NOT NULL,
  buys BIGINT NOT NULL,
  sells BIGINT NOT NULL
);



CREATE TABLE t_kline_15m (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_30m (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_1h (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_4h (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_12h (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_1d (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_1w (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_1mo (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_kline_1y (LIKE t_kline_5m INCLUDING ALL);

CREATE TABLE t_pool (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  chain_id BIGINT NOT NULL,
  address VARCHAR(255) NOT NULL,
  pool_type_id int NOT NULL,
  launchpad_type_id int NOT NULL,
  token0_id BIGINT NOT NULL,
  token1_id BIGINT NOT NULL,
  liquidity0 DECIMAL(60, 0) NOT NULL,
  liquidity1 DECIMAL(60, 0) NOT NULL,
  fee_bps int NOT NULL,
  -- Fee rate charged by the pool (1 for 0.01%)
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL UNIQUE KEY `idx_address` (`address`)
);

CREATE TABLE t_pool_type (
  id INT AUTO_INCREMENT PRIMARY KEY,
  dex_id INT NOT NULL,
  name VARCHAR(255) NOT NULL DEFAULT '',
  version VARCHAR(255) NOT NULL DEFAULT '',
  icon VARCHAR(2000) NOT NULL DEFAULT '',
  website VARCHAR(2000) NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE t_launchpad_type (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL DEFAULT '',
  version VARCHAR(255) NOT NULL DEFAULT '',
  icon VARCHAR(2000) NOT NULL DEFAULT '',
  website VARCHAR(2000) NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE t_dex (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL DEFAULT '',
  version VARCHAR(255) NOT NULL DEFAULT '',
  icon VARCHAR(2000) NOT NULL DEFAULT '',
  website VARCHAR(2000) NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_chain_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `chainid` varchar(128) NOT NULL,
  `real_chainid` varchar(128) NOT NULL,
  `name` varchar(64) NOT NULL,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `alias_name` varchar(128) NOT NULL,
  `backend` int NOT NULL,
  `eip1559` tinyint(1) NOT NULL,
  `network_code` int NOT NULL,
  `block_interval` int NOT NULL,
  `timeout` int NOT NULL DEFAULT '120',
  `icon` varchar(1024) NOT NULL,
  `rpc_end_point` varchar(1024) NOT NULL,
  `explorer_url` varchar(1024) NOT NULL,
  `gas_token_name` varchar(64) NOT NULL,
  `gas_token_address` varchar(128) NOT NULL,
  `gas_token_decimal` int NOT NULL,
  `gas_token_icon` varchar(128) NOT NULL DEFAULT '',
  `transfer_native_gas` int NOT NULL,
  `transfer_erc20_gas` int NOT NULL,
  `deposit_gas` int DEFAULT NULL,
  `withdraw_gas` int DEFAULT NULL,
  `layer1` varchar(128) DEFAULT NULL,
  `mainnet` varchar(64) DEFAULT NULL,
  `transfer_contract_address` varchar(128) DEFAULT NULL,
  `disabled` tinyint(1) NOT NULL DEFAULT '0',
  `is_testnet` tinyint(1) NOT NULL DEFAULT '0',
  `order_weight` int NOT NULL DEFAULT '1000',
  `deposit_contract_address` varchar(128),
  `official_rpc` varchar(1024) NOT NULL,
  `official_bridge` varchar(128) NOT NULL DEFAULT '',
  `mev_rpc_url` varchar(1024) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `network_code` (`network_code`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_node_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `chain_id` bigint NOT NULL,
  `rpc_url` varchar(750) NOT NULL,
  `type` int NOT NULL,
  `usability` int DEFAULT '100',
  PRIMARY KEY (`id`),
  UNIQUE KEY `chain_id_rpc_url` (`chain_id`, `rpc_url`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_kv` (
  `key` varchar(255) NOT NULL,
  `value` text,
  PRIMARY KEY (`key`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tag_name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_tag_name` (`tag_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_object_tag` (
  `object_table` varchar(64) NOT NULL,
  `object_id` bigint NOT NULL,
  `tag_id` bigint NOT NULL,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`object_table`, `tag_id`, `object_id`),
  KEY `idx_object` (`object_table`, `object_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_token_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `token_name` varchar(128) NOT NULL,
  `chain_name` varchar(64) NOT NULL,
  `token_address` varchar(128) NOT NULL,
  `decimals` int NOT NULL,
  `full_name` varchar(128) NOT NULL DEFAULT '',
  `total_supply` decimal(64, 0) NOT NULL DEFAULT '0',
  `discover_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `icon` varchar(1024) NOT NULL DEFAULT '',
  `twitter` varchar(1024) NOT NULL DEFAULT '',
  `telegram` varchar(1024) NOT NULL DEFAULT '',
  `website` varchar(1024) NOT NULL DEFAULT '',
  `discord` varchar(1024) NOT NULL DEFAULT '',
  `mcap` double NOT NULL DEFAULT '0',
  `fdv` double NOT NULL DEFAULT '0',
  `volume24h` double NOT NULL DEFAULT '0',
  `volume6h` double NOT NULL DEFAULT '0',
  `volume1h` double NOT NULL DEFAULT '0',
  `volume5m` double NOT NULL DEFAULT '0',
  `pricechg24h` double NOT NULL DEFAULT '0',
  `pricechg6h` double NOT NULL DEFAULT '0',
  `pricechg1h` double NOT NULL DEFAULT '0',
  `pricechg5m` double NOT NULL DEFAULT '0',
  `comment` varchar(2048) NOT NULL DEFAULT '',
  `priceu` double NOT NULL DEFAULT '0',
  `liquidity` double NOT NULL DEFAULT '0',
  `txbuy24h` int NOT NULL DEFAULT '0',
  `txbuy6h` int NOT NULL DEFAULT '0',
  `txbuy1h` int NOT NULL DEFAULT '0',
  `txbuy5m` int NOT NULL DEFAULT '0',
  `txsell24h` int NOT NULL DEFAULT '0',
  `txsell6h` int NOT NULL DEFAULT '0',
  `txsell1h` int NOT NULL DEFAULT '0',
  `txsell5m` int NOT NULL DEFAULT '0',
  `flags` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_chain_name_token_address` (`chain_name`, `token_address`),
  KEY `idx_token_name` (`token_name`),
  KEY `idx_insert_timestamp` (`insert_timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_event_processed_block` (
  `chainid` int NOT NULL,
  `appid` int NOT NULL,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `block_number` bigint NOT NULL,
  `latest_block_number` bigint DEFAULT NULL,
  `backtrack_block_number` bigint NOT NULL,
  PRIMARY KEY (`chainid`, `appid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_gapped_block` (
  `chainid` int NOT NULL,
  `appid` int NOT NULL,
  `block_number` bigint NOT NULL,
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_processed` int NOT NULL,
  PRIMARY KEY (`chainid`, `appid`, `block_number`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_transfer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `chainid` int NOT NULL,
  `from_address` varchar(128) NOT NULL,
  `to_address` varchar(128) NOT NULL,
  `value` varchar(128) NOT NULL,
  `is_processed` int NOT NULL DEFAULT '0',
  `is_invalid` int NOT NULL DEFAULT '0',
  `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hash` varchar(128) NOT NULL DEFAULT '',
  `source_table` varchar(64) NOT NULL,
  `source_item_id` bigint NOT NULL,
  `token_address` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_source_table_item_id` (`source_table`, `source_item_id`),
  KEY `idx_process_invalid_inser` (`is_processed`, `is_invalid`, `insert_timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE t_user_account (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  -- 用户唯一标识符，主键，自增
  status INT NOT NULL DEFAULT 0,
  -- 账号状态，默认0
  main_uid VARCHAR(255) NOT NULL,
  -- oauth uid，唯一
  main_email VARCHAR(255) NOT NULL DEFAULT '',
  -- 用户邮箱
  main_provider VARCHAR(255) NOT NULL DEFAULT '',
  -- 用户邮箱
  aux_uid VARCHAR(255) NOT NULL,
  -- 辅助uid
  aux_provider VARCHAR(255) NOT NULL DEFAULT '',
  -- 渠道
  aux_email VARCHAR(255) NOT NULL DEFAULT '',
  -- 用户邮箱
  create_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  -- 账号创建时间，默认为当前时间
  update_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  -- 账号最后更新时间，自动更新时间
  -- Define unique constraints
  UNIQUE KEY idx_main_uid (main_uid),
  UNIQUE KEY idx_aux_uid (aux_uid),
  KEY idx_main_email (main_email),
  KEY idx_aux_email (aux_email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE t_user_address (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  -- 主键，自增，作为唯一标识符
  uid BIGINT,
  -- 用户标识符
  sn INT,
  -- 地址组序号
  network INT,
  -- 网络类型 (1: EVM, 2: StarkNet, 3: Solana, 4: BTC)
  address VARCHAR(255),
  -- 存储地址，最大长度为 128 字符
  create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- 创建时间，默认当前时间
  update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  -- 更新时间，自动更新为当前时间
  -- Indexes
  INDEX idx_uid (uid) -- 用户ID建立索引
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- CREATE TABLE `t_token_info` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `token_name` varchar(128) NOT NULL,
--     `chain_name` varchar(64) NOT NULL,
--     `token_address` varchar(128) NOT NULL,
--     `decimals` int NOT NULL,
--     `full_name` varchar(128) NOT NULL DEFAULT '',
--     `total_supply` DECIMAL(64, 0) NOT NULL DEFAULT 0,
--     `discover_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `icon` varchar(1024) NOT NULL DEFAULT '',
--     `twitter` varchar(1024) NOT NULL DEFAULT '',
--     `telegram` varchar(1024) NOT NULL DEFAULT '',
--     `website` varchar(1024) NOT NULL DEFAULT '',
--     `discord` varchar(1024) NOT NULL DEFAULT '',
--     `comment` varchar(2048) NOT NULL DEFAULT '',
--     `mcap` DOUBLE NOT NULL DEFAULT 0,
--     `fdv` DOUBLE NOT NULL DEFAULT 0,
--     `priceu` DOUBLE NOT NULL DEFAULT 0,
--     `liquidity` DOUBLE NOT NULL DEFAULT 0,
--     `volume24h` DOUBLE NOT NULL DEFAULT 0,
--     `volume6h` DOUBLE NOT NULL DEFAULT 0,
--     `volume1h` DOUBLE NOT NULL DEFAULT 0,
--     `volume5m` DOUBLE NOT NULL DEFAULT 0,
--     `pricechg24h` DOUBLE NOT NULL DEFAULT 0,
--     `pricechg6h` DOUBLE NOT NULL DEFAULT 0,
--     `pricechg1h` DOUBLE NOT NULL DEFAULT 0,
--     `pricechg5m` DOUBLE NOT NULL DEFAULT 0,
--     `txbuy24h` int NOT NULL DEFAULT 0,
--     `txbuy6h` int NOT NULL DEFAULT 0,
--     `txbuy1h` int NOT NULL DEFAULT 0,
--     `txbuy5m` int NOT NULL DEFAULT 0,
--     `txsell24h` int NOT NULL DEFAULT 0,
--     `txsell6h` int NOT NULL DEFAULT 0,
--     `txsell1h` int NOT NULL DEFAULT 0,
--     `txsell5m` int NOT NULL DEFAULT 0,
--     `flags` int NOT NULL DEFAULT 0,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `idx_chain_name_token_address` (`chain_name`, `token_address`),
--     KEY `idx_token_name` (`token_name`),
--     KEY `idx_insert_timestamp` (`insert_timestamp`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_tag` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `tag_name` varchar(128) NOT NULL,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `idx_tag_name` (`tag_name`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_object_tag` (
--     `object_table` varchar(64),
--     `object_id` bigint NOT NULL,
--     `tag_id` bigint NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     PRIMARY KEY (`object_table`, `tag_id`, `object_id`),
--     KEY `idx_object` (`object_table`, `object_id`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_transfer` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `chainid` int NOT NULL,
--     `from_address` varchar(128) NOT NULL,
--     `to_address` varchar(128) NOT NULL,
--     `value` varchar(128) NOT NULL,
--     `is_processed` int NOT NULL DEFAULT '0',
--     `is_invalid` int NOT NULL DEFAULT '0',
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `hash` varchar(128) NOT NULL DEFAULT '',
--     `source_table` varchar(64) NOT NULL,
--     `source_item_id` bigint NOT NULL,
--     `token_address` varchar(128) NOT NULL,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `idx_source_table_item_id` (`source_table`, `source_item_id`),
--     KEY `idx_process_invalid_inser` (`is_processed`, `is_invalid`, `insert_timestamp`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_kv` (
--     `key` varchar(255) NOT NULL,
--     `value` text,
--     PRIMARY KEY (`key`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_event_processed_block` (
--     `chainid` int NOT NULL,
--     `appid` int NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `block_number` bigint NOT NULL,
--     `latest_block_number` bigint DEFAULT NULL,
--     `backtrack_block_number` bigint NOT NULL,
--     PRIMARY KEY (`chainid`, `appid`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_gapped_block` (
--     `chainid` int NOT NULL,
--     `appid` int NOT NULL,
--     `block_number` bigint NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `is_processed` int NOT NULL,
--     PRIMARY KEY (`chainid`, `appid`, `block_number`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_chain_info` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `chainid` varchar(128) NOT NULL,
--     `real_chainid` varchar(128) NOT NULL,
--     `name` varchar(64) NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `alias_name` varchar(128) NOT NULL,
--     `backend` int NOT NULL,
--     `eip1559` tinyint(1) NOT NULL,
--     `network_code` int NOT NULL,
--     `block_interval` int NOT NULL,
--     `timeout` int NOT NULL DEFAULT '120',
--     `icon` varchar(1024) NOT NULL,
--     `rpc_end_point` varchar(1024) NOT NULL,
--     `explorer_url` varchar(1024) NOT NULL,
--     `gas_token_name` varchar(64) NOT NULL,
--     `gas_token_address` varchar(128) NOT NULL,
--     `gas_token_decimal` int NOT NULL,
--     `gas_token_icon` varchar(128) NOT NULL DEFAULT '',
--     `transfer_native_gas` int NOT NULL,
--     `transfer_erc20_gas` int NOT NULL,
--     `deposit_gas` int DEFAULT NULL,
--     `withdraw_gas` int DEFAULT NULL,
--     `layer1` varchar(128) DEFAULT NULL,
--     `mainnet` varchar(64) DEFAULT NULL,
--     `transfer_contract_address` varchar(128) DEFAULT NULL,
--     `disabled` tinyint(1) NOT NULL DEFAULT '0',
--     `is_testnet` tinyint(1) NOT NULL DEFAULT '0',
--     `order_weight` int NOT NULL DEFAULT '1000',
--     `deposit_contract_address` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
--     `official_rpc` varchar(1024) NOT NULL,
--     `official_bridge` varchar(128) NOT NULL DEFAULT '',
--     `mev_rpc_url` varchar(1024) NOT NULL DEFAULT '',
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `name` (`name`),
--     UNIQUE KEY `network_code` (`network_code`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_node_info` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `chain_id` bigint NOT NULL,
--     `rpc_url` varchar(750) NOT NULL,
--     `type` int NOT NULL,
--     `usability` int DEFAULT '100',
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `chain_id_rpc_url` (`chain_id`, `rpc_url`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_account` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `address` varchar(128) NOT NULL,
--     `chain_id` bigint NOT NULL,
--     `initial_nonce` int NOT NULL,
--     `signing_name` varchar(128) DEFAULT NULL,
--     PRIMARY KEY (`id`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_dst_transaction` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `src_action` varchar(128) NOT NULL DEFAULT 'transfer',
--     `src_id` bigint NOT NULL,
--     `src_version` int NOT NULL DEFAULT '0',
--     `sender` bigint NOT NULL,
--     `body` mediumtext NOT NULL,
--     `nonce` int DEFAULT NULL,
--     `snonce` varchar(128) DEFAULT NULL,
--     `confirmed_gen` bigint DEFAULT NULL,
--     `fee_cap` varchar(128) DEFAULT NULL,
--     `jail_til` int DEFAULT NULL,
--     `transfer_token` varchar(128) DEFAULT NULL,
--     `transfer_recipient` varchar(128) DEFAULT NULL,
--     `transfer_amount` varchar(128) DEFAULT NULL,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `src_key` (`src_action`, `src_id`, `src_version`),
--     KEY `sender_nonce_jail` (`sender`, `nonce`, `jail_til`),
--     KEY `idx_sender_confirm_gen_nonce` (`sender`, `confirmed_gen`, `nonce`),
--     KEY `transfer_recipient` (`transfer_recipient`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_dst_transaction_gen` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `build_timestamp` bigint NOT NULL,
--     `tx_id` bigint NOT NULL,
--     `raw` mediumtext NOT NULL,
--     `hash` mediumtext NOT NULL,
--     `gas_price` varchar(128) NOT NULL,
--     `gas_price_prio` varchar(128) NOT NULL,
--     `gas_price_level` int NOT NULL,
--     `placeholder` tinyint(1) NOT NULL DEFAULT '0',
--     `confirmed_height` bigint DEFAULT NULL,
--     `confirmed_gas_used` bigint DEFAULT NULL,
--     `confirmed_gas_price` varchar(128) DEFAULT NULL,
--     `confirmed_tx_fee` varchar(128) DEFAULT NULL,
--     `confirmed_success` tinyint(1) DEFAULT NULL,
--     PRIMARY KEY (`id`),
--     KEY `idx_tx_id` (`tx_id`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_dst_confirmed_queue` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `src_action` varchar(64) NOT NULL,
--     `src_id` bigint NOT NULL,
--     `src_version` int NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `tx_id` bigint NOT NULL,
--     `tx_gen_id` bigint NOT NULL,
--     `tx_gen_hash` varchar(128) NOT NULL,
--     `block` bigint DEFAULT NULL,
--     `gas_used` bigint DEFAULT NULL,
--     `gas_price` varchar(128) DEFAULT NULL,
--     `tx_fee` varchar(128) DEFAULT NULL,
--     `success` tinyint(1) NOT NULL,
--     `placeholder` tinyint(1) NOT NULL,
--     `is_testnet` int NOT NULL DEFAULT '0',
--     PRIMARY KEY (`id`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_token_info` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `token_name` varchar(128) NOT NULL,
--     `chain_name` varchar(128) NOT NULL,
--     `token_address` varchar(128) NOT NULL,
--     `decimals` int NOT NULL,
--     `icon` varchar(128) NOT NULL,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `chain_name_token_name` (`chain_name`, `token_name`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_exchange_info` (
--     `id` int NOT NULL,
--     `name` varchar(64) NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `icon` varchar(1024) NOT NULL,
--     `disabled` tinyint(1) NOT NULL DEFAULT '0',
--     `official_url` varchar(1024) NOT NULL,
--     `order_weight` int NOT NULL,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `name` (`name`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_cctp_support_chain` (
--     `chainid` int NOT NULL,
--     `min_value` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `domain` int NOT NULL DEFAULT '-1',
--     `token_messenger` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `message_transmitter` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     PRIMARY KEY (`chainid`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_src_transaction` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `chainid` int NOT NULL,
--     `tx_hash` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `sender` varchar(128) COLLATE utf8_bin NOT NULL,
--     `receiver` varchar(128) COLLATE utf8_bin NOT NULL,
--     `target_address` varchar(128) COLLATE utf8_bin DEFAULT NULL,
--     `token` varchar(128) COLLATE utf8_bin NOT NULL,
--     `value` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `is_processed` int NOT NULL DEFAULT '0',
--     `is_invalid` int NOT NULL DEFAULT '0',
--     `dst_chainid` int DEFAULT NULL,
--     `dst_tx_hash` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `dst_value` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `is_verified` int DEFAULT '0',
--     `dst_gas` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `dst_gas_used` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `dst_gas_price` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `is_testnet` int DEFAULT NULL,
--     `next_time` int NOT NULL DEFAULT '0',
--     `bridge_fee` varchar(128) COLLATE utf8_bin NOT NULL DEFAULT '0',
--     `src_nonce` int NOT NULL DEFAULT '-1',
--     `dst_nonce` int NOT NULL DEFAULT '-1',
--     `dst_estimated_gas_limit` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `dst_estimated_gas_price` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `dst_max_fee_per_gas` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `tx_timestamp` int NOT NULL DEFAULT '2147483647',
--     `is_locked` int NOT NULL DEFAULT '0',
--     `src_token_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `src_token_decimal` int DEFAULT NULL,
--     `gas_token_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
--     `gas_token_decimal` int DEFAULT NULL,
--     `is_manual` int DEFAULT '0',
--     `is_cctp` int NOT NULL DEFAULT '0',
--     `cctp_status` int NOT NULL DEFAULT '0',
--     `dst_token_decimal` int DEFAULT NULL,
--     `thirdparty_channel` int NOT NULL DEFAULT '0',
--     `process_timestamp` int NOT NULL DEFAULT '0',
--     `verified_timestamp` int NOT NULL DEFAULT '0',
--     `to_exchange` int NOT NULL DEFAULT '0',
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `tx_hash_chainid` (`tx_hash`, `chainid`),
--     UNIQUE KEY `chainid_tx_hash` (`chainid`, `tx_hash`),
--     KEY `dst_chainid_dst_tx_hash` (`dst_chainid`, `dst_tx_hash`),
--     KEY `dst_chainid_dst_nonce` (`dst_chainid`, `dst_nonce`),
--     KEY `chainid_sender_src_nonce` (`chainid`, `sender`, `src_nonce`),
--     KEY `bridge_query_index` (
--         `is_invalid`,
--         `is_verified`,
--         `is_locked`,
--         `dst_chainid`,
--         `is_processed`
--     ),
--     KEY `sender` (`sender`),
--     KEY `target_address` (`target_address`),
--     KEY `sign_query_index` (`sender`, `is_verified`, `insert_timestamp`),
--     KEY `null_dstchainid_query` (`dst_chainid`, `is_testnet`),
--     KEY `insert_timestamp` (`insert_timestamp`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_lp_info` (
--     `version` int NOT NULL,
--     `token_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `from_chain` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `to_chain` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `maker_address` varchar(128) COLLATE utf8_bin NOT NULL,
--     `min_value` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `max_value` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `dtc` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `bridge_fee_ratio` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
--     `is_disabled` int NOT NULL DEFAULT '0',
--     PRIMARY KEY (
--         `version`,
--         `token_name`,
--         `from_chain`,
--         `to_chain`,
--         `maker_address`
--     ),
--     UNIQUE KEY `uk_token_chain` (
--         `version`,
--         `token_name`,
--         `from_chain`,
--         `to_chain`
--     )
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_maker_address_groups` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `group_name` varchar(128) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
--     `env` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
--     `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     PRIMARY KEY (`id`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_maker_addresses` (
--     `id` bigint NOT NULL AUTO_INCREMENT,
--     `group_id` bigint NOT NULL DEFAULT '0',
--     `backend` int NOT NULL DEFAULT '0',
--     `address` varchar(128) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
--     `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY `uk_backend_address` (`backend`, `address`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_bridge_fee_decimal` (
--     `token` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `keep_decimal` int NOT NULL,
--     `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     PRIMARY KEY (`token`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_dynamic_bridge_fee` (
--     `token_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `from_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `to_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `bridge_fee_ratio_lv1` bigint NOT NULL DEFAULT '0',
--     `bridge_fee_ratio_lv2` bigint NOT NULL DEFAULT '0',
--     `bridge_fee_ratio_lv3` bigint NOT NULL DEFAULT '0',
--     `bridge_fee_ratio_lv4` bigint NOT NULL DEFAULT '0',
--     `amount_lv1` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv2` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv3` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     PRIMARY KEY (`token_name`, `from_chain`, `to_chain`),
--     UNIQUE KEY `token_name_from_chain_to_chain` (`token_name`, `from_chain`, `to_chain`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
-- CREATE TABLE `t_dynamic_dtc` (
--     `token_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `from_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `to_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `dtc_lv1` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `dtc_lv2` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `dtc_lv3` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `dtc_lv4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv1` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv2` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv3` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     `amount_lv4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
--     PRIMARY KEY (`token_name`, `from_chain`, `to_chain`),
--     UNIQUE KEY `token_name_from_chain_to_chain` (`token_name`, `from_chain`, `to_chain`)
-- ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;