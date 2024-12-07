module supra::coins {
    use std::signer;
    use std::string::utf8;
    use supra_framework::supra_coin; 
    use supra_framework::coin::{Self, MintCapability, BurnCapability};

    // use aptos_framework::coin::{Self, MintCapability, BurnCapability};

    /// Represents test USDT coin.
    struct USDT {}

    /// Represents test BTC coin.
    struct BTC {}

    /// Represents test USDC coin.
    struct USDC {}

    /// Represents test ETH coin.
    struct ETH {}

    /// Represents APT coin.
    struct APT {}

    /// Represents THL coin
    struct THL {}

    // Represents SUPRA coin
    struct SUPRA {}

    /// Storing mint/burn capabilities for `USDT` and `BTC` coins under user account.
    struct Caps<phantom CoinType> has key {
        mint: MintCapability<CoinType>,
        burn: BurnCapability<CoinType>,
    }

    /// Initializes `BTC` and `USDT` coins.
    public entry fun register_coins(token_admin: &signer) {
        let (btc_b, btc_f, btc_m) =
            coin::initialize<BTC>(token_admin,
                utf8(b"Bitcoin"), utf8(b"BTC"), 8, true);
        let (usdt_b, usdt_f, usdt_m) =
            coin::initialize<USDT>(token_admin,
                utf8(b"Tether"), utf8(b"USDT"), 6, true);
        let (eth_b, eth_f, eth_m) =
            coin::initialize<ETH>(token_admin,
                utf8(b"Ethereum"), utf8(b"ETH"), 8, true);
        let (usdc_b, usdc_f, usdc_m) =
            coin::initialize<USDC>(token_admin,
                utf8(b"USD Coin"), utf8(b"USDC"), 6, true);
        let (apt_b, apt_f, apt_m) =
            coin::initialize<APT>(token_admin,
                utf8(b"APT"), utf8(b"APT"), 8, true);
        let (thl_b, thl_f, thl_m) =
            coin::initialize<THL>(token_admin,
                utf8(b"THL"), utf8(b"THL"), 8, true);
        let (supra_b, supra_f, supra_m) =
            coin::initialize<SUPRA>(token_admin,
                utf8(b"SUPRA"), utf8(b"SUPRA"), 8, true);

        coin::destroy_freeze_cap(eth_f);
        coin::destroy_freeze_cap(usdc_f);
        coin::destroy_freeze_cap(apt_f);
        coin::destroy_freeze_cap(thl_f);
        coin::destroy_freeze_cap(btc_f);
        coin::destroy_freeze_cap(usdt_f);
        coin::destroy_freeze_cap(supra_f);

        move_to(token_admin, Caps<ETH> { mint: eth_m, burn: eth_b });
        move_to(token_admin, Caps<USDC> { mint: usdc_m, burn: usdc_b });
        move_to(token_admin, Caps<APT> { mint: apt_m, burn: apt_b });
        move_to(token_admin, Caps<THL> { mint: thl_m, burn: thl_b });
        move_to(token_admin, Caps<BTC> { mint: btc_m, burn: btc_b });
        move_to(token_admin, Caps<USDT> { mint: usdt_m, burn: usdt_b });
        move_to(token_admin, Caps<SUPRA> { mint: supra_m, burn: supra_b });
    }

    fun ensure_coin_store<CoinType>(account: &signer) {
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<CoinType>(account_addr)) {
            coin::register<CoinType>(account);
        };
    }

    /// Mints new coin `CoinType` on account `acc_addr`.
    public entry fun mint_coin<CoinType>(token_admin: &signer, acc_addr: address, amount: u64) acquires Caps {
        let account_addr= signer::address_of(token_admin);
        // First ensure the account has a coin store
        ensure_coin_store<CoinType>(token_admin);

        let token_admin_addr = signer::address_of(token_admin);
        let caps = borrow_global<Caps<CoinType>>(token_admin_addr);
        let coins = coin::mint<CoinType>(amount, &caps.mint);
        coin::deposit(acc_addr, coins);
        // aptos_account::deposit_coins(acc_addr, coins);
    }
}