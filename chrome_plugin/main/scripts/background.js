// Generated by CoffeeScript 2.7.0
(function() {
  console.log("background.js");

  // 设置顶部快捷按钮是否触发side panel
  // await chrome.sidePanel.setPanelBehavior({ openPanelOnActionClick: false })
  chrome.runtime.onMessage.addListener(function(message, sender) {
    var message_content, message_type;
    console.log("[background]chrome.runtime.onMessage.addListener");
    console.log(message);
    console.log(sender);
    message_type = message.type;
    if (message_type === "setIcon") {
      message_content = message.content;
      return chrome.action.setIcon(message_content, () => {
        console.log("message_type:", message_type);
        return console.log("message_content:", message_content);
      });
    }
  });

}).call(this);
