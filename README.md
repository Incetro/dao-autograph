DAO autograph
=====

Imagine you want to save your objects in a database. It's not complicated so often, but little amount of engineers understand databases completely. This leads to buggy code, especially if you pass objects through threads and so on. 
In this situation you can abstract from specific database and use iniversal CRUD interface. So you can use our library called [DAO](https://github.com/Incetro/DAO).
The problem is your count of model objects increases more boilerplate code you should type. This library will help you to save your time writing Translators and database objects (Model) based on plain objects classes annotations.

Now supports Realm database and Swift language.

See more [DAO](https://github.com/Incetro/DAO).

Just remember one simple annotation – `@realm`.

Let's imagine you have entity class:

```swift
// MARK: - BookPlainObject

/// @realm
struct BookPlainObject: Plain {

    var uniqueId: UniqueID {
        .init(value: id)
    }

    /// Books unique identifier
    let id: Int

    /// Book's name
    let name: String

    /// Book's author
    let author: AuthorPlainObject

    /// Book's genre
    let genre: Genre
}
```

Generator will generate two classes in separate files. Model class:

```swift
// MARK: - BookModelObject

final class BookModelObject: RealmModel {

    // MARK: - Properties

    /// Books unique identifier
    @objc dynamic var id = 0

    /// Book's name
    @objc dynamic var name = ""

    /// Book's author
    @objc dynamic var author: AuthorModelObject?

    /// Book's genre
    @objc dynamic var genre = ""
}
```

And translator class:

```swift
// MARK: - BookTranslator

final class BookTranslator {

    // MARK: - Aliases

    typealias PlainModel = BookPlainObject
    typealias DatabaseModel = BookModelObject

    /// Book storage
    private lazy var bookStorage = RealmStorage<BookModelObject>(configuration: self.configuration)

    /// RealmConfiguration instance
    private let configuration: RealmConfiguration

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - configuration: current realm db config
    init(configuration: RealmConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - Translator

extension BookTranslator: Translator {

    func translate(model: DatabaseModel) throws -> PlainModel {
        guard let author = model.author else {
            throw NSError(
                domain: "com.incetro.author-translator",
                code: 1000,
                userInfo: [
                    NSLocalizedDescriptionKey: "Cannot find AuthorModelObject instance for BookPlainObject with id: '\(model.uniqueId)'"
                ]
            )
        }
        return BookPlainObject(
            id: model.id,
            name: model.name,
            author: try AuthorTranslator(configuration: configuration).translate(model: author),
            genre: Genre(rawValue: model.genre).unwrap()
        )
    }

    func translate(plain: PlainModel) throws -> DatabaseModel {
        let model = try bookStorage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
        try translate(from: plain, to: model)
        return model
    }

    func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
        if databaseModel.uniqueId.isEmpty {
            databaseModel.uniqueId = plain.uniqueId.rawValue
        }
        databaseModel.id = plain.id
        databaseModel.name = plain.name
        databaseModel.author = try AuthorTranslator(configuration: configuration).translate(plain: plain.author)
        databaseModel.genre = plain.genre.rawValue
    }
}
```

You can note that `BookPlainObject` structure documentation includes `@realm` annotation, that means generate model and translator for that.

Table provides reference for type convertion from Plain to Model properties:

| Type   	| Non-optional                     | Optional                            |
|--------	|----------------------------------|-------------------------------------|
| Bool   	| dynamic var value = false        | let value = RealmOptional\<Bool>()  |
| Int    	| dynamic var value = 0            | let value = RealmOptional\<Int>()   |
| Float  	| dynamic var value: Float = 0.0   | let value = RealmOptional\<Float>() |
| Double 	| dynamic var value: Double = 0.0  | let value = RealmOptional\<Double>()|
| String 	| dynamic var value: String = ""   | dynamic var value: String?          |
| Data   	| dynamic var value: Data = Data() | dynamic var value: Data?            |
| Date   	| dynamic var value: Date = Date() | dynamic var value: Date?            |
| Object 	| n/a: must be optional            | dynamic var value: Class?           |
| Array   | let value = List\<Class>()       | n/a: must be non-optional           |

## Setup steps

**1. Add submodule to your project.**

`git@github.com:Incetro/dao-autograph`

**2. Init submodules in your project.**

```bash
git submodule init
git submodule update
```

**3. Run `spm_build.command` to build executable file.**

You should take it from `.build/release/dao-autograph` and place inside your project folder (for example in folder `Codegen`)

**4. Add run script phase in Xcode.**

It may look like this:

```bash
DAO_AUTOGRAPH_PATH=Codegen/dao-autograph

if [ -f $DAO_AUTOGRAPH_PATH ]
then
    echo "dao-autograph executable found"
else
    osascript -e 'tell app "Xcode" to display dialog "DAO generator executable not found in \nCodegen/dao-autograph" buttons {"OK"} with icon caution'
fi

$DAO_AUTOGRAPH_PATH \
    -translators "$SRCROOT/$PROJECT_NAME/Translators" \
    -plains "$SRCROOT/$PROJECT_NAME/Models/Plains" \
    -models "$SRCROOT/$PROJECT_NAME/Models/Database" \
    -enums "$SRCROOT/$PROJECT_NAME/Models/Enums" \
    -project_name $PROJECT_NAME

```

Available arguments

| Parameter         | Description                                                                       | Example                                                      |
|-------------------|-----------------------------------------------------------------------------------|--------------------------------------------------------------|
| help              | Print help info                                                                   | `./dao-autograph -help`                                      |
| projectName       | Project name to be used in generated files                                        | `./dao-autograph -projectName yourName`                      |
| enums             | Path to the folder, where enums files to be processed are stored                  | `./dao-autograph -enums "./Models/Enums"`                    |
| plains            | Path to the folder, where plain objects files to be processed are stored          | `./dao-autograph -plains "./Models/Plain"`                   |
| models            | Path to the folder, where generated model files should be placed                  | `./dao-autograph -models "./Models/Database"`                |
| translators       | Path to the folder, where generated translator files should be placed             | `./dao-autograph -translators "./BusinessLayer/Translators"` |
| verbose           | Forces generator to print the whole process of generation                         | `./dao-autograph -verbose`                                   |

**5. Add generated files manually to your project.**

### Example project

You can see how it works in the exmaple folder `Sources/sandbox`. Run `sandbox_run.command` and then there will be several options to test the generator:

1. You can add or remove some property from any current plain object, open the object's translator file and press `Cmd B` – you'll see how it changes
2. You can clear any translator file and press `Cmd B` – you will see that translator will be generated
3. Eventually, you can create a new plain object and press `Cmd B` – model and translator classes will be placed inside folders `Models/Database/` and `Translators/` (but you should still add them manually to project)
