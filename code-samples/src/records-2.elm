type alias Dog =
    { name : String
    , age : Int
    , breed : String
    }

dog : Dog
dog =
    { name = "Tucker"
    , age = 11
    , breed = "Sheltie"
    }

dog = Dog "Tucker" 11 "Sheltie"
