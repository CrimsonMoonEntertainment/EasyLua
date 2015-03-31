--[[
function AddBuyAllIfNeeded()
    -- First, we start out and see if we have any of the BuyAllGunPurchases
    collection_manager = bridge:wrap(class.iGunCollection)("sharediGunCollection")
    local all_guns_owned_1 = collection_manager("IsItemOwned:", "AllGuns")
    local all_guns_owned_2 = collection_manager("IsItemOwned:", "AllGuns2")

    local bool_test = collection_manager("returnBool:", true)
    print("bool Test:")
    print(bool_test)

    print(all_guns_owned_2)

    -- Don't present if we already own
    if all_guns_owned_1 == 1 or all_guns_owned_2 == 1 then
    print("Aborting Split Test! - You Already Own it")
    return
end
]]

print("Continuing Split Test ")
bridge:wrap(class.ObjCTest)("returnFalse:", "Test")

