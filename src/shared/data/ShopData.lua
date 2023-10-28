--[[
ShopData
27, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]


return {
    Bundles = {
        {
            Price = { --If developer product then comment out price
                Amount = 10,
                Currency = "Cash"
            },

            Items = {
                --Items given on purchase
            },
        }
    },
    Items = {
        Price = { --If developer product then comment out price
            Amount = 10,
            Currency = "Cash"
        },

        Item = nil --The item given on purchase
    },
    Unboxables = {
        Price = { --If developer product then comment out price
            Amount = 10,
            Currency = "Cash",
        },
        DropList = {
            {
                Type = "Item",
                Weight = 10, --The higher the weight compared to others the higher the chance is of getting the item.
                Item = nil --The item which should be given
            },
            {
                Type = "Currency",
                Weight = 10,
                Currency = "Cash",
                Amount = 10,
            }
        }
    },
}