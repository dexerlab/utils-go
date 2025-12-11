CREATE TABLE `t_token_info` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `token_name` varchar(128) NOT NULL,
    `chain_name` varchar(64) NOT NULL,
    `token_address` varchar(128) NOT NULL,
    `decimals` int NOT NULL,
    `full_name` varchar(128) NOT NULL DEFAULT '',
    `total_supply` DECIMAL(64, 0) NOT NULL DEFAULT 0,
    `discover_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `icon` varchar(1024) NOT NULL DEFAULT '',
    `twitter` varchar(1024) NOT NULL DEFAULT '',
    `telegram` varchar(1024) NOT NULL DEFAULT '',
    `website` varchar(1024) NOT NULL DEFAULT '',
    `discord` varchar(1024) NOT NULL DEFAULT '',
    `comment` varchar(2048) NOT NULL DEFAULT '',
    `mcap` DOUBLE NOT NULL DEFAULT 0,
    `fdv` DOUBLE NOT NULL DEFAULT 0,
    `price` DOUBLE NOT NULL DEFAULT 0,
    `liquidity` DOUBLE NOT NULL DEFAULT 0,
    `volume24h` DOUBLE NOT NULL DEFAULT 0,
    `volume6h` DOUBLE NOT NULL DEFAULT 0,
    `volume1h` DOUBLE NOT NULL DEFAULT 0,
    `volume5m` DOUBLE NOT NULL DEFAULT 0,
    `pricechg24h` DOUBLE NOT NULL DEFAULT 0,
    `pricechg6h` DOUBLE NOT NULL DEFAULT 0,
    `pricechg1h` DOUBLE NOT NULL DEFAULT 0,
    `pricechg5m` DOUBLE NOT NULL DEFAULT 0,
    `txbuy24h` int NOT NULL DEFAULT 0,
    `txbuy6h` int NOT NULL DEFAULT 0,
    `txbuy1h` int NOT NULL DEFAULT 0,
    `txbuy5m` int NOT NULL DEFAULT 0,
    `txsell24h` int NOT NULL DEFAULT 0,
    `txsell6h` int NOT NULL DEFAULT 0,
    `txsell1h` int NOT NULL DEFAULT 0,
    `txsell5m` int NOT NULL DEFAULT 0,
    `flags` int NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_chain_name_token_address` (`chain_name`, `token_address`),
    KEY `idx_token_name` (`token_name`),
    KEY `idx_insert_timestamp` (`insert_timestamp`)
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
    `object_table` varchar(64),
    `object_id` bigint NOT NULL,
    `tag_id` bigint NOT NULL,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`object_table`, `tag_id`, `object_id`),
    KEY `idx_object` (`object_table`, `object_id`)
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

CREATE TABLE `t_kv` (
    `key` varchar(255) NOT NULL,
    `value` text,
    PRIMARY KEY (`key`)
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
    `deposit_contract_address` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
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

CREATE TABLE `t_account` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `address` varchar(128) NOT NULL,
    `chain_id` bigint NOT NULL,
    `initial_nonce` int NOT NULL,
    `signing_name` varchar(128) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_dst_transaction` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `src_action` varchar(128) NOT NULL DEFAULT 'transfer',
    `src_id` bigint NOT NULL,
    `src_version` int NOT NULL DEFAULT '0',
    `sender` bigint NOT NULL,
    `body` mediumtext NOT NULL,
    `nonce` int DEFAULT NULL,
    `snonce` varchar(128) DEFAULT NULL,
    `confirmed_gen` bigint DEFAULT NULL,
    `fee_cap` varchar(128) DEFAULT NULL,
    `jail_til` int DEFAULT NULL,
    `transfer_token` varchar(128) DEFAULT NULL,
    `transfer_recipient` varchar(128) DEFAULT NULL,
    `transfer_amount` varchar(128) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `src_key` (`src_action`, `src_id`, `src_version`),
    KEY `sender_nonce_jail` (`sender`, `nonce`, `jail_til`),
    KEY `idx_sender_confirm_gen_nonce` (`sender`, `confirmed_gen`, `nonce`),
    KEY `transfer_recipient` (`transfer_recipient`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_dst_transaction_gen` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `build_timestamp` bigint NOT NULL,
    `tx_id` bigint NOT NULL,
    `raw` mediumtext NOT NULL,
    `hash` mediumtext NOT NULL,
    `gas_price` varchar(128) NOT NULL,
    `gas_price_prio` varchar(128) NOT NULL,
    `gas_price_level` int NOT NULL,
    `placeholder` tinyint(1) NOT NULL DEFAULT '0',
    `confirmed_height` bigint DEFAULT NULL,
    `confirmed_gas_used` bigint DEFAULT NULL,
    `confirmed_gas_price` varchar(128) DEFAULT NULL,
    `confirmed_tx_fee` varchar(128) DEFAULT NULL,
    `confirmed_success` tinyint(1) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_tx_id` (`tx_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_dst_confirmed_queue` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `src_action` varchar(64) NOT NULL,
    `src_id` bigint NOT NULL,
    `src_version` int NOT NULL,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `tx_id` bigint NOT NULL,
    `tx_gen_id` bigint NOT NULL,
    `tx_gen_hash` varchar(128) NOT NULL,
    `block` bigint DEFAULT NULL,
    `gas_used` bigint DEFAULT NULL,
    `gas_price` varchar(128) DEFAULT NULL,
    `tx_fee` varchar(128) DEFAULT NULL,
    `success` tinyint(1) NOT NULL,
    `placeholder` tinyint(1) NOT NULL,
    `is_testnet` int NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_token_info` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `token_name` varchar(128) NOT NULL,
    `chain_name` varchar(128) NOT NULL,
    `token_address` varchar(128) NOT NULL,
    `decimals` int NOT NULL,
    `icon` varchar(128) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `chain_name_token_name` (`chain_name`, `token_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_exchange_info` (
    `id` int NOT NULL,
    `name` varchar(64) NOT NULL,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `icon` varchar(1024) NOT NULL,
    `disabled` tinyint(1) NOT NULL DEFAULT '0',
    `official_url` varchar(1024) NOT NULL,
    `order_weight` int NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_cctp_support_chain` (
    `chainid` int NOT NULL,
    `min_value` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `domain` int NOT NULL DEFAULT '-1',
    `token_messenger` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `message_transmitter` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    PRIMARY KEY (`chainid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_src_transaction` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `chainid` int NOT NULL,
    `tx_hash` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `sender` varchar(128) COLLATE utf8_bin NOT NULL,
    `receiver` varchar(128) COLLATE utf8_bin NOT NULL,
    `target_address` varchar(128) COLLATE utf8_bin DEFAULT NULL,
    `token` varchar(128) COLLATE utf8_bin NOT NULL,
    `value` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `is_processed` int NOT NULL DEFAULT '0',
    `is_invalid` int NOT NULL DEFAULT '0',
    `dst_chainid` int DEFAULT NULL,
    `dst_tx_hash` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `dst_value` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `is_verified` int DEFAULT '0',
    `dst_gas` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `dst_gas_used` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `dst_gas_price` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `is_testnet` int DEFAULT NULL,
    `next_time` int NOT NULL DEFAULT '0',
    `bridge_fee` varchar(128) COLLATE utf8_bin NOT NULL DEFAULT '0',
    `src_nonce` int NOT NULL DEFAULT '-1',
    `dst_nonce` int NOT NULL DEFAULT '-1',
    `dst_estimated_gas_limit` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `dst_estimated_gas_price` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `dst_max_fee_per_gas` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `tx_timestamp` int NOT NULL DEFAULT '2147483647',
    `is_locked` int NOT NULL DEFAULT '0',
    `src_token_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `src_token_decimal` int DEFAULT NULL,
    `gas_token_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    `gas_token_decimal` int DEFAULT NULL,
    `is_manual` int DEFAULT '0',
    `is_cctp` int NOT NULL DEFAULT '0',
    `cctp_status` int NOT NULL DEFAULT '0',
    `dst_token_decimal` int DEFAULT NULL,
    `thirdparty_channel` int NOT NULL DEFAULT '0',
    `process_timestamp` int NOT NULL DEFAULT '0',
    `verified_timestamp` int NOT NULL DEFAULT '0',
    `to_exchange` int NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `tx_hash_chainid` (`tx_hash`, `chainid`),
    UNIQUE KEY `chainid_tx_hash` (`chainid`, `tx_hash`),
    KEY `dst_chainid_dst_tx_hash` (`dst_chainid`, `dst_tx_hash`),
    KEY `dst_chainid_dst_nonce` (`dst_chainid`, `dst_nonce`),
    KEY `chainid_sender_src_nonce` (`chainid`, `sender`, `src_nonce`),
    KEY `bridge_query_index` (
        `is_invalid`,
        `is_verified`,
        `is_locked`,
        `dst_chainid`,
        `is_processed`
    ),
    KEY `sender` (`sender`),
    KEY `target_address` (`target_address`),
    KEY `sign_query_index` (`sender`, `is_verified`, `insert_timestamp`),
    KEY `null_dstchainid_query` (`dst_chainid`, `is_testnet`),
    KEY `insert_timestamp` (`insert_timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_lp_info` (
    `version` int NOT NULL,
    `token_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `from_chain` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `to_chain` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `maker_address` varchar(128) COLLATE utf8_bin NOT NULL,
    `min_value` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `max_value` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `dtc` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `bridge_fee_ratio` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    `is_disabled` int NOT NULL DEFAULT '0',
    PRIMARY KEY (
        `version`,
        `token_name`,
        `from_chain`,
        `to_chain`,
        `maker_address`
    ),
    UNIQUE KEY `uk_token_chain` (
        `version`,
        `token_name`,
        `from_chain`,
        `to_chain`
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_maker_address_groups` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `group_name` varchar(128) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
    `env` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_maker_addresses` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `group_id` bigint NOT NULL DEFAULT '0',
    `backend` int NOT NULL DEFAULT '0',
    `address` varchar(128) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_backend_address` (`backend`, `address`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_bridge_fee_decimal` (
    `token` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `keep_decimal` int NOT NULL,
    `update_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `insert_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`token`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_dynamic_bridge_fee` (
    `token_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `from_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `to_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `bridge_fee_ratio_lv1` bigint NOT NULL DEFAULT '0',
    `bridge_fee_ratio_lv2` bigint NOT NULL DEFAULT '0',
    `bridge_fee_ratio_lv3` bigint NOT NULL DEFAULT '0',
    `bridge_fee_ratio_lv4` bigint NOT NULL DEFAULT '0',
    `amount_lv1` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv2` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv3` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    PRIMARY KEY (`token_name`, `from_chain`, `to_chain`),
    UNIQUE KEY `token_name_from_chain_to_chain` (`token_name`, `from_chain`, `to_chain`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `t_dynamic_dtc` (
    `token_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `from_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `to_chain` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `dtc_lv1` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `dtc_lv2` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `dtc_lv3` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `dtc_lv4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv1` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv2` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv3` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    `amount_lv4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
    PRIMARY KEY (`token_name`, `from_chain`, `to_chain`),
    UNIQUE KEY `token_name_from_chain_to_chain` (`token_name`, `from_chain`, `to_chain`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;