/*:
 Here you see the end result, the Tower Defence Game.
 
 Tap on "Run My Code", build some towers by tapping on a free tower build place and tap on "Start Next Wave" in the top right corner. The Goal of this game is to not let the enemies escape and reach the end of the path. You get money for every killed enemy, that you need for building new towers. You will lost a live if you let enemies escape.
 
 Play around to get a feeling for what you will create on the next pages.
 You can pinch to zoom and scroll with one finger.
 
 For best experience turn sound on 🔈 and go into fullscreen mode.
 
 After you finished your experiment start with your first challenge.
 
 BTW: You can find the Source Code of this Playgroundbook on [GitHub](https://github.com/dnadoba/games-and-math-playgroundbook)
 */
//#-hidden-code
//#-code-completion(everything, hide)

import PlaygroundSupport

let gameController = PlaygroundViewController.shared
gameController.automaticallyBuildFirstTowers = false
gameController.automaticallyStartFirstWave = false
PlaygroundPage.current.liveView = gameController
validatePlayground()

//#-end-hidden-code
