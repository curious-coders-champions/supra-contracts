module router::router {
    use std::object;
    use std::signer;
    use std::string;
    use std::timestamp;
    use aptos_std::math64;
    use aptos_std::type_info;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::aptos_account;
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::fungible_asset::Metadata;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::resource_account;

    use executor::executor;

    const FEE_PRECISION: u64 = 10000;

    /// Require admin permission
    const ENOT_AUTHORIZED: u64 = 1;

    /// Amount out not enough
    const ENOT_ENOUGH_OUT: u64 = 2;

    /// Token must be fungible asset or coin within type args
    const EINVALID_TOKEN: u64 = 3;

    struct Configs has key {
        signer_cap: SignerCapability,
        platform: address,
        swap_fee: u64,
    }

    /// Indicate that the type is not present
    struct Null {}

    #[event]
    /// Event emitted when a swap happens.
    struct Swap has drop, store {
        in_coin: string::String,
        in_fa: address,
        out_coin: string::String,
        out_fa: address,
        amount_in: u64,
        amount_out: u64,
        fee: u64,
        user: address,
        timestamp: u64,
    }

    fun init_module(resource_signer: &signer) {
        let signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, @deployer);
        move_to(resource_signer, Configs { signer_cap, platform: @deployer, swap_fee: 200 });
    }

    public entry fun swap_exact_in<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(
        caller: &signer,
        in_cid: u8,
        in_fa: address,
        out_cid: u8,
        out_fa: address,
        amount_in: u64,
        min_amount_out: u64,
        recipient: address,
        data: vector<u8>
    ) acquires Configs {
        transfer<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(caller, @router, in_cid, in_fa, amount_in);
        let cfg = borrow_global<Configs>(@router);
        let router_signer = &account::create_signer_with_capability(&cfg.signer_cap);
        executor::swap_exact_in<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(router_signer, data);
        let amount_out = balance<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(@router, out_cid, out_fa);
        let fee = math64::mul_div(amount_out, cfg.swap_fee, FEE_PRECISION);
        amount_out = amount_out - fee;
        assert!(amount_out >= min_amount_out, ENOT_ENOUGH_OUT);
        transfer<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(router_signer, cfg.platform, out_cid, out_fa, fee);
        transfer<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(router_signer, recipient, out_cid, out_fa, amount_out);
        event::emit(
            Swap {
                in_coin: type_name<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(in_cid),
                in_fa,
                out_coin: type_name<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(out_cid),
                out_fa,
                amount_in,
                amount_out,
                fee,
                user: signer::address_of(caller),
                timestamp: timestamp::now_seconds()
            }
        );
    }

    public entry fun set_swap_fee(platform: &signer, new_swap_fee: u64) acquires Configs {
        let configs = platform_only_mut_configs(platform);
        configs.swap_fee = new_swap_fee;
    }

    public entry fun set_platform(platform: &signer, new_platform: address) acquires Configs {
        let configs = platform_only_mut_configs(platform);
        configs.platform = new_platform;
    }

    public fun transfer<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(
        sender: &signer,
        recipient: address,
        cid: u8,
        fa: address,
        amount: u64
    ) {
        if (fa != @0) {
            assert!(cid == 0, EINVALID_TOKEN);
            primary_fungible_store::transfer(sender, object::address_to_object<Metadata>(fa), recipient, amount);
        } else {
            if (cid == 1) aptos_account::transfer_coins<T1>(sender, recipient, amount)
            else if (cid == 2) aptos_account::transfer_coins<T2>(sender, recipient, amount)
            else if (cid == 3) aptos_account::transfer_coins<T3>(sender, recipient, amount)
            else if (cid == 4) aptos_account::transfer_coins<T4>(sender, recipient, amount)
            else if (cid == 5) aptos_account::transfer_coins<T5>(sender, recipient, amount)
            else if (cid == 6) aptos_account::transfer_coins<T6>(sender, recipient, amount)
            else if (cid == 7) aptos_account::transfer_coins<T7>(sender, recipient, amount)
            else if (cid == 8) aptos_account::transfer_coins<T8>(sender, recipient, amount)
            else if (cid == 9) aptos_account::transfer_coins<T9>(sender, recipient, amount)
            else if (cid == 10) aptos_account::transfer_coins<T10>(sender, recipient, amount)
            else abort EINVALID_TOKEN;
        };
    }

    public fun balance<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(user: address, cid: u8, fa: address): u64 {
        if (fa != @0) {
            assert!(cid == 0, EINVALID_TOKEN);
            primary_fungible_store::balance(user, object::address_to_object<Metadata>(fa))
        } else {
            if (cid == 1) coin_balance<T1>(user)
            else if (cid == 2) coin_balance<T2>(user)
            else if (cid == 3) coin_balance<T3>(user)
            else if (cid == 4) coin_balance<T4>(user)
            else if (cid == 5) coin_balance<T5>(user)
            else if (cid == 6) coin_balance<T6>(user)
            else if (cid == 7) coin_balance<T7>(user)
            else if (cid == 8) coin_balance<T8>(user)
            else if (cid == 9) coin_balance<T9>(user)
            else if (cid == 10) coin_balance<T10>(user)
            else abort EINVALID_TOKEN
        }
    }

    fun type_name<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(id: u8): string::String {
        if (id == 1) type_info::type_name<T1>()
        else if (id == 2) type_info::type_name<T2>()
        else if (id == 3) type_info::type_name<T3>()
        else if (id == 4) type_info::type_name<T4>()
        else if (id == 5) type_info::type_name<T5>()
        else if (id == 6) type_info::type_name<T6>()
        else if (id == 7) type_info::type_name<T7>()
        else if (id == 8) type_info::type_name<T8>()
        else if (id == 9) type_info::type_name<T9>()
        else if (id == 10) type_info::type_name<T10>()
        else  type_info::type_name<Null>()
    }

    inline fun platform_only_mut_configs(platform: &signer): &mut Configs acquires Configs {
        let configs =  borrow_global_mut<Configs>(@router);
        assert!(signer::address_of(platform) == configs.platform, ENOT_AUTHORIZED);
        configs
    }

    inline fun coin_balance<CoinType>(user: address): u64 {
        if (coin::is_account_registered<CoinType>(user)) coin::balance<CoinType>(user) else 0
    }

    #[test(framework = @1, user = @10)]
    fun test_transfer_balance_coin(framework: &signer, user: &signer) {
        use aptos_framework::account;
        use aptos_framework::aptos_account;
        use aptos_framework::aptos_coin::{Self, AptosCoin};

        let user_addr = signer::address_of(user);
        account::create_account_for_test(user_addr);
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(framework);
        aptos_account::deposit_coins(user_addr, coin::mint(1000, &mint_cap));

        transfer<AptosCoin, Null, Null, Null, Null, Null, Null, Null, Null, Null>(user, @11, 1, @0, 10);
        transfer<Null, AptosCoin, Null, Null, Null, Null, Null, Null, Null, Null>(user, @11, 2, @0, 10);
        transfer<Null, Null, AptosCoin, Null, Null, Null, Null, Null, Null, Null>(user, @11, 3, @0, 10);
        transfer<Null, Null, Null, AptosCoin, Null, Null, Null, Null, Null, Null>(user, @11, 4, @0, 10);
        transfer<Null, Null, Null, Null, AptosCoin, Null, Null, Null, Null, Null>(user, @11, 5, @0, 10);
        transfer<Null, Null, Null, Null, Null, AptosCoin, Null, Null, Null, Null>(user, @11, 6, @0, 10);
        transfer<Null, Null, Null, Null, Null, Null, AptosCoin, Null, Null, Null>(user, @11, 7, @0, 10);
        transfer<Null, Null, Null, Null, Null, Null, Null, AptosCoin, Null, Null>(user, @11, 8, @0, 10);
        transfer<Null, Null, Null, Null, Null, Null, Null, Null, AptosCoin, Null>(user, @11, 9, @0, 10);
        transfer<Null, Null, Null, Null, Null, Null, Null, Null, Null, AptosCoin>(user, @11, 10, @0, 10);

        assert!(balance<AptosCoin, Null, Null, Null, Null, Null, Null, Null, Null, Null>(@11, 1, @0) == 100, 0);
        assert!(balance<Null, AptosCoin, Null, Null, Null, Null, Null, Null, Null, Null>(@11, 2, @0) == 100, 0);
        assert!(balance<Null, Null, AptosCoin, Null, Null, Null, Null, Null, Null, Null>(@11, 3, @0) == 100, 0);
        assert!(balance<Null, Null, Null, AptosCoin, Null, Null, Null, Null, Null, Null>(@11, 4, @0) == 100, 0);
        assert!(balance<Null, Null, Null, Null, AptosCoin, Null, Null, Null, Null, Null>(@11, 5, @0) == 100, 0);
        assert!(balance<Null, Null, Null, Null, Null, AptosCoin, Null, Null, Null, Null>(@11, 6, @0) == 100, 0);
        assert!(balance<Null, Null, Null, Null, Null, Null, AptosCoin, Null, Null, Null>(@11, 7, @0) == 100, 0);
        assert!(balance<Null, Null, Null, Null, Null, Null, Null, AptosCoin, Null, Null>(@11, 8, @0) == 100, 0);
        assert!(balance<Null, Null, Null, Null, Null, Null, Null, Null, AptosCoin, Null>(@11, 9, @0) == 100, 0);
        assert!(balance<Null, Null, Null, Null, Null, Null, Null, Null, Null, AptosCoin>(@11, 10, @0) == 100, 0);
        assert!(balance<AptosCoin, Null, Null, Null, Null, Null, Null, Null, Null, Null>(@12, 1, @0) == 0, 0);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }


    #[test(user = @10)]
    fun test_transfer_balance_fa(user: &signer) {
        use std::option;
        use std::string::{utf8};
        use aptos_framework::account;
        use aptos_framework::fungible_asset;
        use aptos_framework::primary_fungible_store;

        let user_addr = signer::address_of(user);
        account::create_account_for_test(user_addr);
        
        let constructor_ref = &object::create_named_object(user, b"asset");
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref, option::none(), utf8(b""), utf8(b""), 8, utf8(b""), utf8(b""),
        );
        let mint_ref = &fungible_asset::generate_mint_ref(constructor_ref);
        let asset = object::object_address(&fungible_asset::mint_ref_metadata(mint_ref));
        primary_fungible_store::deposit(user_addr, fungible_asset::mint(mint_ref, 1000));

        transfer<Null, Null, Null, Null, Null, Null, Null, Null, Null, Null>(user, @11, 0, asset, 100);
        assert!(balance<Null, Null, Null, Null, Null, Null, Null, Null, Null, Null>(@11, 0, asset) == 100, 0);
        assert!(balance<Null, Null, Null, Null, Null, Null, Null, Null, Null, Null>(@12, 0, asset) == 0, 0);
    }

    #[test(router = @router, deployer = @deployer, platform = @10)]
    fun test_platform_func(router: &signer, deployer: &signer, platform: &signer) acquires Configs {
        let signer_cap = account::create_test_signer_cap(@router);
        move_to(router, Configs {signer_cap, platform: @deployer, swap_fee: 200});
        set_swap_fee(deployer, 300);
        assert!(borrow_global_mut<Configs>(@router).swap_fee == 300, 0);
        set_platform(deployer, signer::address_of(platform));
        set_swap_fee(platform, 100);
        assert!(borrow_global_mut<Configs>(@router).swap_fee == 100, 0);
    }

    #[test(router = @router, intruder = @10)]
    #[expected_failure(abort_code = ENOT_AUTHORIZED, location = Self)]
    fun test_set_fee_auth(router: &signer, intruder: &signer) acquires Configs {
        let signer_cap = account::create_test_signer_cap(@router);
        move_to(router, Configs {signer_cap, platform: @deployer, swap_fee: 200});
        set_swap_fee(intruder, 300);
    }

    #[test(router = @router, deployer = @deployer, intruder = @10)]
    #[expected_failure(abort_code = ENOT_AUTHORIZED, location = Self)]
    fun test_set_platform_auth(router: &signer, deployer: &signer, intruder: &signer) acquires Configs {
        let signer_cap = account::create_test_signer_cap(@router);
        move_to(router, Configs {signer_cap, platform: @deployer, swap_fee: 200});
        set_platform(deployer, @11);
        set_platform(intruder, @10);
    }
}
