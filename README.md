
# InfinityScrollKit Package

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpierrejanineh-com%2FInfinityScrollKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pierrejanineh-com/InfinityScrollKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpierrejanineh-com%2FInfinityScrollKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pierrejanineh-com/InfinityScrollKit)

`InfinityScrollKit` is a SwiftUI package that simplifies implementing infinite scrolling for lists in iOS. The package handles loading more items as the user scrolls, while providing a customizable UI for both normal cells and the last loading/error state cell.

## Features
- Infinite scrolling support for any SwiftUI list.
- Customizable views for individual items and the last cell (used for progress indicators or error states).
- Support for dynamic loading through a callback for loading more items.
- Encapsulated state management for loading indicators.
- Option to provide feedback to parent views about loading state changes.
- Scroll orientation customization.

## Installation
### Swift Package Manager
Add the package by going to your Xcode project:
1.  Select your project in the file navigator.
2.  Choose the project or target where you want to add the package.
3.  Go to the Package Dependencies tab.
4.  Click the `+` button.
5.  Search for `InfinityScrollKit` using the repository URL:
    ```bash
    https://github.com/PierreJanineh-com/InfinityScrollKit
    ```
6.  Follow the prompts to complete the installation.

### CocoaPods
1.  If you are not yet using CocoaPods in your project, first run `sudo gem install cocoapods` followed by `pod init`. (For further information on installing CocoaPods, [click here](https://guides.cocoapods.org/using/getting-started.html#installation).)

2.  Add the following to your Podfile (inside the target section):
    ```bash
    pod 'InfinityScrollKit'
    ```
3.  Run `pod install`.

## Usage
> Check out the full example in this [repo](https://github.com/PierreJanineh-com/ISK-Example).

### Basic Usage
Below is a basic usage example where we create an infinite scroll list with custom item and last cell views:

```swift
import SwiftUI
import InfiniteScrollView

struct ContentView: View {
    @State private var items: [MyItem] = []
    
    var body: some View {
        InfiniteScrollView(
            arr: items,
            cellView: { item in
                Text(item.name) // Customize the view for each item
            }
        )
    }
}
```
- `arr`: The array of items to display.
- `cellView`: A `ViewBuilder` function to display the individual cells in the list.

### Customization
- `onLoadingChange`: A closure to notify the parent view when the loading state changes.
- `options`: You can pass `Options<T>` to customize the number of items per page and handle loading more items via a callback.
- `lastCellView`: A `ViewBuilder` function for the view at the end of the list (e.g., a loading indicator or error message).
- `emptyArrayView`: Customize the view shown when there are no items in the list.

```swift
import SwiftUI
import InfinityScrollKit

struct ContentView: View {
    @State private var arr: [String] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        InfiniteScrollView(
            arr: arr,
            options: options,
            onLoadingChanged: onLoadingChanged,
            cellView: CellView,
            lastCellView: LastCellView,
            emptyArrView: EmptyArrView
        )
        // You can also use ScrollView modifiers directly
        .scrollIndicators(.hidden)
    }

    private var options: Options<String> {
        .init(
            orientation: .horizontal,
            countPerPage: 2,
            paginationOptions: .init(
                onPageLoad: {
                    // Replace this with an API pagination request
                    try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                    for i in arr.count...arr.count + 10 {
                        arr.append("Cell #\(i)")
                    }
                    return arr
                },
                concatMode: .auto  //.auto for automatically adding pages to the array instead of passing the full array everytime.
            )
        )
    }

    private func onLoadingChanged(_ isLoading: Bool) {
        self.isLoading = isLoading
        if self.isLoading {
            // Do anything here...
        }
    }

    @ViewBuilder func CellView(_ item: String) -> some View {
        Text(item)
    }

    @ViewBuilder func LastCellView() -> some View {
        ProgressView()
            .padding()
    }

    @ViewBuilder func EmptyArrView() -> some View {
        Text("No items to display...")
    }
}
```

## Platforms
The InfiniteScrollView package supports the following platforms:
- iOS 14.0+
- macOS 14.0+
- watchOS 7.0+
- tvOS 14.0+
- visionOS 1.0+

## Contribution
Feel free to contribute by creating issues or submitting pull requests. Before submitting, make sure to:
1.  Fork the repository.
2.  Create your feature branch `(git checkout -b feature/my-feature)`.
3.  Commit your changes `(git commit -m 'Add some feature')`.
4.  Push to the branch `(git push origin feature/my-feature)`.
5.  Open a pull request.

## License
This project is licensed under the **MIT License**. See the **LICENSE** file for more details.
