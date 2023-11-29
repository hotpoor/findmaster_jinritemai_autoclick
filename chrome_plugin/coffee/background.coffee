console.log "background.js"
# 设置顶部快捷按钮是否触发side panel
# await chrome.sidePanel.setPanelBehavior({ openPanelOnActionClick: false })
chrome.runtime.onMessage.addListener (message, sender)->
    console.log "[background]chrome.runtime.onMessage.addListener"
    console.log message
    console.log sender
    message_type = message.type
    if message_type in ["setIcon"]
        message_content = message.content
        chrome.action.setIcon message_content,()=>
            console.log "message_type:",message_type
            console.log "message_content:",message_content

