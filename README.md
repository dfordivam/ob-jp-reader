# Test for ghcjs vs wasm performance

The text reflow algorithm implemented here is quite resource intensive, and hence to make it work properly some delay in the retry event is needed.

See https://github.com/dfordivam/ob-jp-reader/blob/master/frontend/src/ReadingPane.hs#L399

The algorithm itself is simple binary search, but the DOM building is resource intensive.

with less delay the algorithm does not take the best possible path to the result, and actually causes the more time for the page to be "ready".

# Results

The below is a comparison of the delay value vs the time algorithm takes to come to finish on the first page load ( with the default settings of 400px height and 120% font size.)

All experiments were done on laptop with Chromium 80.0.3987.116, i7-8550U, 16gb RAM.

For each I tried at least 2 times, the results are reproducible with less than 1s error.


| Delay | Warp | GHCJS | Wasm |
|-------|------|-------|------|
| 0.8   | 10   | 31    | 22   |
| 0.9   | 11   |       | 12   |
| 1.0   | 12   | 33    | 13   |
| 1.1   | 14   | 34    | 14   |
| 1.2   | 16   | 35    |      |
| 1.3   | 16   | 37    |      |
| 1.4   | 18   | 37    |      |
| 1.5   | 20   | 22    |      |

PS: I noticed that on Chrome on Windows, with Surface i5 10th gen, the performance of both ghcjs and wasm is better than above. Though wasm still performs better than ghcjs.

# Analysis

With ghcjs for the best possible page load time we need 1.5s delay, wherease wasm need 1s, which is a considerable improvement.

For Jsaddle-warp we could make the delay as low as 0.3s, (giving a page load time of 3s), so there is a lot more room for improvement.

The absolute values of 22s and 12s are not that important, as they are specific to this particular algorithm, but show that the small slowdowns can add up to bigger differences.

I think the reason we have this difference in ghcjs and wasm is primarily due to the ghcjs constrained to a single thread (the main thread)
Since the main thread has to do all the DOM related things as well as the haskell runtime, it chokes at lower delay values.

The wasm on the other hand is able to make use of more CPU resources, sometimes even going up to 500% usage.

The wasm seems to consume slightly more RAM.

ghcjs (1.5s delay)
RAM: 1.3%

Wasm (0.9s delay)
RAM: 1.7%

# Hack

Use `nix-build -A linuxExe` on master branch for ghcjs and wasm branch for WebGHC/wasm.


# Hosted apps

|Delay| URL|
|-----|----|
| 0.5 |https://dfordivam.github.io/ob-jp-reader/wasm05/|
| 0.8 |https://dfordivam.github.io/ob-jp-reader/wasm08/|
| 1   |https://dfordivam.github.io/ob-jp-reader/wasm1/|

|Delay| URL|
|-----|----|
| 0.5 |https://dfordivam.github.io/ob-jp-reader/ghcjs05/|
| 0.8 |https://dfordivam.github.io/ob-jp-reader/ghcjs08/|
| 1   |https://dfordivam.github.io/ob-jp-reader/ghcjs1/|
| 1.2 |https://dfordivam.github.io/ob-jp-reader/ghcjs12/|
| 1.5 |https://dfordivam.github.io/ob-jp-reader/ghcjs15/|
