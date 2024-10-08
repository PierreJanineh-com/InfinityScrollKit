# ``InfinityScrollKit``

`InfinityScrollKit` is a SwiftUI package that simplifies implementing infinite scrolling for lists in iOS. The package handles loading more items as the user scrolls, while providing a customizable UI for both normal cells and the last loading/error state cell.

## Features
- Infinite scrolling support for any SwiftUI list.
- Customizable views for individual items and the last cell (used for progress indicators or error states).
- Support for dynamic loading through a callback for loading more items.
- Encapsulated state management for loading indicators.
- Option to provide feedback to parent views about loading state changes.

## Installation
### Swift Package Manager
Add the package by going to your Xcode project:
1.  Select your project in the file navigator.
2.  Choose the project or target where you want to add the package.
3.  Go to the Package Dependencies tab.
4.  Click the `+` button.
5. Search for `InfinityScrollKit` using the repository URL:
    ```bash
    https://github.com/PierreJanineh-com/InfinityScrollKit
    ```
6.  Follow the prompts to complete the installation.

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
            countPerPage: 2,
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
