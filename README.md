# Places

The **Places App** is a SwiftUI application that displays a list of places around the world. Users can tap on a place to be redirected to the Wikipedia app for more information about that location under the Places tab

## Archecture

The app follows the common SwiftUI **Model-View (MV)** architecture:

- **Model**: Represents DTOs and @State models, such as `PlacesListModel`.
- **View**: SwiftUI views that handle UI rendering. The views are kept as "dumb" as possible.
- **ViewModel**: Acts as the central place for all the business logic, handling data transformations, validations, state management, and network requests/ aggreegation /caching using the use case . Each screen or feature has a dedicated ViewModel, like `PlacesListViewModel`.

## File Structure
.
├── Places
│   ├── PlacesApp.swift
│   ├── PlacesList
│   │   ├── Models
│   │   │   ├── PlacesListModel.swift
│   │   │   ├── PlacesListViewModel.swift
│   │   │   └── PlacesResponse.swift
│   │   ├── UseCase
│   │   │   └── PlasesUseCase.swift
│   │   └── View
│   │       └── PlacesListView.swift
│   ├── Preview Content
│   │   └── Preview Assets.xcassets
│   │       └── Contents.json
│   └── Service
│       └── PlacesService.swift
├── PlacesTests
│   └── PlacesTests.swift
├── README.md

- **PlacesList**: Contains the Places Screen/Feature each subsequent screen/feature will have this file struture define in this directory
  - **Models**: Defines the ViewModel and the DTO and @State Models used by the view/views of this feature.
  - **UseCase**: This is where we decide we decide where we going to fetch our data from, there might be a per service class, it also defines a "declarative" way in which we fetch data from the server in which we simply specify the URL and HTTP menthod.
  - **View**: This will contain the main SwiftUI View some component view that will eventually be used by the main swiftUI View.
- **Service**: This contains the service class that will be used by all screens in our app to easily make network calls this will/can handle authentication and appending the approriate headers.
- **Tests**: Unit tests for the app, testing the viewModel

## Getting Started

1. Clone the repository.
2. Open `Places.xcodeproj` in Xcode.
3. Build and run the project using a simulator or device.


