#  DKCodable

DKCodable solves what I personally find to be a glaring hole in Swift's `JSON*coder`s. I would love to not use it, but the alternatives aren't acceptable in my opinion.

### The problem

Say you have an API that is documented to return this schema for a "post" object:

```json
{
    "id": number,
    "author_name": string | null,
    "author_username": string,
    "title": string,
    "created_at": string,
    "bookmarked": boolean,
    "ignored": boolean,
    ... etc
}
```

Looks pretty straightforward, right? Your model might look like this:

```swift
struct Post: Codable {
    var id: Int
    var authorName: String? = nil
    var authorUsername: String
    var title: String
    var createdAt: Date
    var bookmarked: Bool
    var ignored: Bool
    ...
}
```

Then you write an API client and run some tests. You get a decoding error: `No value associated with key "bookmarked"`. Uh oh... How is that possible? The key doesn't even have a null value, it's just *missing*. Not only that, but after looking at the response, you notice other keys are missing too (and some have `null` values when something like `false` would make sense), and as far as you can tell, these things have a sensible default, so there's no reason they should be null or missing:

```json
{
    "id": 5,
    "author_name": "John Appleseed",
    "author_username": "tima_apple",
    "title": "What's a computer?",
    "created_at": "2017-11-08T01:58:38.000Z"
}
```

You do some research, just to be sure. You create a post and bookmark it, and now `"bookmarked": true` appears in the response. You unbookmark it and check the response again, and now you get `"bookmarked": false`, like you expected the first time. What do you do next?

### Working around missing keys

Right off the bat, you know you can't just give these properties a default value of `nil`. `JSONDecoder` will always fail to decode an object with missing keys. If JSONDecoder were a little more flexible or a little smarter, maybe you could tell it to ignore duplicate keys for `Optional` properties. But JSONDecoder isn't that smart.

Maybe if Codable had some mechanism for providing default values for missing keys, we could use that, but it doesn't. It sure would be neat if you codable had an API for querying default values for specific keys, though.

You seek help online, and after hours or even days of research, you realize the only "idiomatic" workaround is to manually implement the synthesized Decodable initializer:

```swift
struct Post: Codable {
    var id: Int
    var authorName: String? = nil
    var authorUsername: String
    var title: String
    var createdAt: Date
    var bookmarked: Bool
    var ignored: Bool
    ...

    init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try json.decode(Int.self, forKey: CodingKeys.id)
        self.authorName = try json.decode(String.self, forKey: CodingKeys.authorName)
        self.authorUsername = try json.decode(String.self, forKey: CodingKeys.authorUsername)
        self.title = try json.decode(String.self, forKey: CodingKeys.title)
        self.createdAt = try json.decode(Date.self, forKey: CodingKeys.createdAt)
        self.bookmarked = (try? json.decode(Bool.self, forKey: CodingKeys.bookmarked)) ?? false
        self.ignored = (try? json.decode(Bool.self, forKey: CodingKeys.ignored)) ?? false
        ...
    }
}
```

Wow, that's not pretty. There's a lot of code duplication here: we're using each property name three times in the entire file, and we even have to specify the type when decoding even though [Swift's type inference should allow us to omit it](https://twitter.com/NSExceptional/status/937524068835905536). I like to think whoever wrote this knows something I don't. I can see why specifying the type manually might be useful, but there should also be a version of `decode` which infers the type.

Anyway, almost all of this could and *should* be automated. And it is! Unfortunately when we need to deviate from the synthesized implementation of Codable, even just a little, we have to implement it all by hand. There's no way to invoke parts of the synthesized implementation, and there's no reflection API we could use to automate the whole process (yet).

At this point you're pulling your hair out wondering what you should do. If you're like me, you don't want to take on the burden that is implementing possibly dozens of possibly huge initializers by hand. Codable was clearly not designed with buggy or poorly designed JSON APIs in mind. If you're like me, you'd rather do anything else out of spite for such a limiting Swift API, even if it means losing some compile-time type-saftey. So, you do.

### Enter DKCodable

DKCodable works by wrapping the JSONEncoder API. You tell it what type you want to decode, you give it some Data (or a JSON object as a dictionary), and it uses what I call "poor man's reflection" to preemptively insert default values for missing keys.

DKCodable defines one property, and provides a default implementation:

```swift
public protocol DKCodable: Codable {
    static var defaults: [String: Any] { get }
}

public extension DKCodable {
    static var defaults: [String: Any] {
        return [:]
    }

    ...
}
```

When you implement DKCodable, if your API never returns missing keys or inappropriate null values, you don't have to do anything. If you want to provide defaults for missing keys or null values *without making your types nullable*, implement `defaults`.

```swift
public struct Person: DKCodable, Equatable {
    var name: String
    var age: Int
    var married: Bool
    var kids: [Person]
    var job: String?
    
    public static var defaults: [String: Any] {
        return [
            "married": false,
            "kids": [] as JSONValue,
            "job": NSNull(), // NSNull for nil values
            "kids_foreach": Person.self
        ]
    }
}
```

Let's look closely at what's happening in our `defaults` implementation:

- `married` is never supposed to be anything but `true` or `false`—null wouldn't make sense here—so we provide a default value of `false`.
- Same with `kids`—a null makes no sense here, it should just be empty. This will have the desired effect whether `kids` is `null` or missing from the response entirely.
- We set `job` to `NSNull()` because we found that the `"job"` key was usually missing in the response, and we would have to implement the previously-synthesized initializer just to specify a default value. (Simply declaring the property like `var job: String? = nil` would not help us here)
- When you have a relationship between one `DKCodable` type and another, like how some people have kids and some don't, what DKCodable allows you to do is specify a type for the elements of that collection. You do this by taking the key name and appending `_foreach`, then giving it a type. We already said `kids` shoudl have a default value of an empty array, but when it's not empty, we need to tell DKCodable the type of the objects in that list so it can give their missing keys default values too. Since our kids are also `Person`s, we pass `Person.self` to `"kids_foreach"`.

If you happened to want to have another property named `kids_foreach`, you could, but then you wouldn't be able to specify the type for `kids` in `defaults`.
