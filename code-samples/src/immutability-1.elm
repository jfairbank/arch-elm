dog = Dog "Tucker" 11 "Sheltie"

olderDog = { dog | age = dog.age + 1 }

dog.age      -- 11
olderDog.age -- 12
