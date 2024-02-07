# Knonw issues

## User initialization error

Fireship provides `my` as global variable. This holds login user's UserModel object. And if you are going to use it without initializing `UserService`, it will throw an exception of `Null check operator used on a null value`.
