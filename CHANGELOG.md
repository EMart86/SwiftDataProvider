## What's new in

### 1.9.1

* fixes where DynamicContentProviderAdapter has not been exposed

### 1.9.0

* Added .reload(), because you sometimes want to update the recycler view without animations
* You can't access to the header or footer of the section directly anymore. Set the header with section.set(header: <Any type or model>) or the footer with section.set(footer: <Any type or model>)

### 1.8.2

Fix: class models can't be used for dequeuing a cell

### 1.8.1

Update Gifs

### 1.8

Remove necessaty of compareable porotocol used for inserting or delete of contents in the section.

### 1.7

Customize your inserted, reloaded or deleted content with given animations.
Can you imagine the struggle to switch between a login or register on the same screen? Or when you want to show or hide a date picker, when tapping on a cell? Now that struggle has been solved. Remove the cell you want to replace and add or insert them at the specific position.
```
func toggleRegisterOrLogin() {
    section.clear()

    if isLoginPresent {
        isLoginPresent = false

        section.add(row: TextEnterCell.Content(title: "E-Mail", content: email, isSecure: false, delegate: self), animation: .fade)
        section.add(row: TextEnterCell.Content(title: "First name", content: firstName, isSecure: false, delegate: self), animation: .fade)
        section.add(row: TextEnterCell.Content(title: "Last name", content: lastName, isSecure: false, delegate: self), animation: .fade)
        //... any further content that has to be filled
    } else {
        isLoginPresent = true

        section.add(row: TextEnterCell.Content(title: "E-Mail", content: email, isSecure: false, delegate: self), animation: .fade)
        section.add(row: TextEnterCell.Content(title: "Password", content: "", isSecure: true, delegate: self), animation: .fade)
    }    
}
```

I once was asked, how easy it was to show a text as a cell with this simple library. Now that's pretty easy:
In the UITableViewController add following lines to your code:
```
dataProvider.register(cell: UITableViewCell.self, for: String.self) { cell, content in
    cell.textLabel?.text = content
}
```
Now add a string to your section:
```
section.add("Hello World")
```
We remove pain for you! Have fun(c)!

### 1.6

Bugfix where the system and custom TableHeaderFooter View have not been displayed: we had to intercept UITableView's delegate, because the ```viewForHeaderInSection``` and ```viewForFooterInSection```is only located in there (?). If you would like to be able to use the delegate without breaking the SwiftDataProviders Section Header and Footer display logic, just assign to the delegate before creating the SwiftDataProvider. It will intercept only the methods that ask for the Header- and Footer View and forward any other delegate callback to your logic

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    //do assign to the tableviews delegate ALWAY BEFORE creating and assigning
    //the SwiftDataProvider to the UITableView or UITableViewController, otherwhise
    //the section header and footer view won't appear, when you handle them within the SwiftDataProvider
    self.tableViewDelegate = self 

    self.swiftDataProvider = SwiftDataProvider(recyclerView: self)

    //step 4
}
```

Added:
Register Header Footer view with nibs
``` swift
    dataProvider.registerHeaderFooter(nib: HeaderView.nib(), as: HeaderView.self, for: HeaderView.HeaderContent.self) { _, _ in 
        // initialize the header view here
    }
}
```

### 1.5

So, we reviewed our code and rethought of how we could improve and reduce code and there your are:

1) No need for those Generics in SwiftDataProvider
```swift
private var swiftDataProvider: SwiftDataProvider?
```
2) No need to explicitly set the swiftDataProvider as the dataSource (we do that implicitly)
```swift
//tableView.dataSource = swiftDataProvider
```
3) DEPRECATIONS: Every ```register(::)``` methods have now been moved to SwiftDataProvider (due to code simplifying)

If you have any problems with using this classes, please file an issue. I'd be happy with every feedback/codereview!
