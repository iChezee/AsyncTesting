import Foundation

class ContentViewModel: ObservableObject {
    @MainActor @Published var names = [NameModel]()
    @MainActor @Published var usingViewModel = UsingViewModel.customActor
    
    private var currentTask: Task<(), Never>?
    
    init() {
        Task {
            await self.switchViewModel()
        }
    }
    
    @MainActor
    func switchViewModel() {
        currentTask?.cancel()
        currentTask = nil
        usingViewModel = usingViewModel == .async ? .customActor : .async
        names.removeAll()
        currentTask = Task {
            switch usingViewModel {
            case .async:
                let models = await ContentAsyncModel().fetchMockedData().sorted()
                if Task.isCancelled { return }
                self.names = models
            case .customActor:
                let models = await ContentCustomActorModel.shared.fetchMockedData().sorted()
                if Task.isCancelled { return }
                await MainActor.run {
                    self.names = models
                }
            }
        }
    }
}

extension ContentViewModel {
    enum UsingViewModel {
        case async
        case customActor
    }
}
