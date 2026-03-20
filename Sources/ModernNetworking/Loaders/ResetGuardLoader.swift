//
//  ResetGuardLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

public class ResetGuardLoader: HTTPLoader {

    private actor State {
        private var isResetting = false

        func beginReset() -> Bool {
            guard isResetting == false else { return false }
            isResetting = true
            return true
        }

        func finishReset() {
            isResetting = false
        }

        func currentlyResetting() -> Bool {
            isResetting
        }
    }

    private let state = State()

    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        if await state.currentlyResetting() == false {
            return await super.load(request)
        }

        return .failure(HTTPError(.resetInProgress, request))
    }

    public override func reset() async {
        guard await state.beginReset() else { return }

        if let nextLoader {
            await nextLoader.reset()
        }

        await state.finishReset()
    }
}
