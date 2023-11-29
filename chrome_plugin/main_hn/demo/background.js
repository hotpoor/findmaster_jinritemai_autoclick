// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import './sw-omnibox.js';
import './sw-tips.js';
console.log("hello, this is background.js")

function reddenPage() {
  document.body.style.backgroundColor = '#f2f2f2';
}

chrome.runtime.onInstalled.addListener(() => {
  chrome.action.setBadgeText({
    text: 'OFF'
  });
  chrome.action.setBadgeTextColor({
    color: "#FFFFFF"
  });
  chrome.action.setBadgeBackgroundColor({
    color: "#000000"
  });
});

const extensions = 'https://developer.chrome.com/docs/extensions';
const webstore = 'https://developer.chrome.com/docs/webstore';

// When the user clicks on the extension action
chrome.action.onClicked.addListener(async (tab) => {
  if (tab.url.startsWith(extensions) || tab.url.startsWith(webstore)) {
    // We retrieve the action badge to check if the extension is 'ON' or 'OFF'
    const prevState = await chrome.action.getBadgeText({ tabId: tab.id });
    // Next state will always be the opposite
    const nextState = prevState === 'ON' ? 'OFF' : 'ON';
    
    // Set the action badge to the next state
    await chrome.action.setBadgeText({
      tabId: tab.id,
      text: nextState
    });

    if (nextState === 'ON') {
      // Insert the CSS file when the user turns the extension on
      await chrome.scripting.insertCSS({
        files: ['focus-mode.css'],
        target: { tabId: tab.id }
      });
      await chrome.action.setBadgeBackgroundColor({
        color: "#4caf50"
      });
      await chrome.action.setBadgeTextColor({
        color: "#000000"
      });

      await chrome.action.setIcon({
        path:{
          "16": "http://cdn0.ofcourse.io/488c518e58114d189b6e0c100832712a_9299918007cc0d9cd8b6fccfd9010a4a?imageView2/2/w/16",
          "32": "http://cdn0.ofcourse.io/488c518e58114d189b6e0c100832712a_9299918007cc0d9cd8b6fccfd9010a4a?imageView2/2/w/32",
          "48": "http://cdn0.ofcourse.io/488c518e58114d189b6e0c100832712a_9299918007cc0d9cd8b6fccfd9010a4a?imageView2/2/w/48",
          "128": "http://cdn0.ofcourse.io/488c518e58114d189b6e0c100832712a_9299918007cc0d9cd8b6fccfd9010a4a?imageView2/2/w/128"
        }
        
      })


      if (!tab.url.includes('chrome://')) {
        chrome.scripting.executeScript({
          target: { tabId: tab.id },
          function: reddenPage
        });
      }


    } else if (nextState === 'OFF') {
      // Remove the CSS file when the user turns the extension off
      await chrome.scripting.removeCSS({
        files: ['focus-mode.css'],
        target: { tabId: tab.id }
      });
      await chrome.action.setBadgeBackgroundColor({
        color: "#000000"
      });
      await chrome.action.setBadgeTextColor({
        color: "#FFFFFF"
      });
      await chrome.action.setIcon({
        path:{
          "16": "images/icon-16.png",
          "32": "images/icon-32.png",
          "48": "images/icon-48.png",
          "128": "images/icon-128.png"
        }
      })
    }
  }
});
