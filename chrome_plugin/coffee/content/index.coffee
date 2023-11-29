root = exports ? this
# !!!! Hotpoor root object
root.Hs or= {}
Hs = root.Hs

Hs.sleep = (ms) ->
    new Promise (resolve) ->
        setTimeout resolve, ms

Hs.setIcon=(dict_content)->
    console.log dict_content
    cmd = ["setIcon",dict_content]
    cmd = JSON.stringify cmd
    console.log cmd
    chrome.runtime.sendMessage cmd
Hs.get_list_timeout = null
Hs.uids=[]

Hs.uids=JSON.parse(localStorage.getItem("a_daren_list"))
if Hs.uids == null
    Hs.uids=[]

Hs.a_daren_list_nub = parseInt(localStorage.getItem("a_daren_list_nub"))
if isNaN(Hs.a_daren_list_nub)
    Hs.a_daren_list_nub = 0

Hs.uids_run = JSON.parse(localStorage.getItem("a_daren_list_run"))
if Hs.uids_run == null
    Hs.uids_run =
        "run":false

Hs.show_info=(info_text)->
    console.log info_text
    $("#findmaster_jinritemai_yaoyue_info").text "#{info_text} 进度#{Hs.a_daren_list_nub}/#{Hs.uids.length}"
Hs.get_list=()->
    Hs.uids=[]
    daren_list_num = 0
    daren_list_str = $(".daren-square-table-warp--card-menu>[elementtiming=element-timing]").text()
    if daren_list_str.indexOf("共")!=0
        Hs.show_info "请选择达人分类"
        alert("请选择达人分类")
        return
    else
        daren_list_num = parseInt(daren_list_str.split("共")[1])
    list_end_dom = $(".sp-infinit-end")
    if list_end_dom.length == 0
        console.log "list_end_dom null"
        daren_cards_num = $(".daren-card").length
        Hs.show_info "#{daren_cards_num}/#{daren_list_num} 正在加载"
        Hs.get_list_timeout = setTimeout ()->
            document.getElementById("portal").scrollTop = document.getElementById("portal").scrollHeight
            Hs.get_list()
        ,2000
    else    
        list_end_str = list_end_dom.text()
        console.log "list_end_dom",list_end_str
        if list_end_str == "已经到底啦"
            clearTimeout Hs.get_list_timeout

            daren_cards = $(".daren-card")
            for daren_card in daren_cards
                _uid = $(daren_card)[0].dataset.itemUid
                if _uid not in Hs.uids
                    Hs.uids.push $(daren_card)[0].dataset.itemUid

            daren_list_str = $(".daren-square-table-warp--card-menu>[elementtiming=element-timing]").text()
            daren_list_num = parseInt(daren_list_str.split("共")[1])

            Hs.a_daren_list_nub = 0
            localStorage.setItem("a_daren_list",JSON.stringify(Hs.uids))
            localStorage.setItem("a_daren_list_nub","#{Hs.a_daren_list_nub}")
            localStorage.setItem("a_daren_list_run",JSON.stringify(Hs.uids_run))

            Hs.show_info "#{Hs.uids.length}/#{daren_list_num} 已经到底啦"
            
Hs.stop_list=()->
    clearTimeout Hs.get_list_timeout
    console.log "停止拉取"
Hs.stop_run=()->
    Hs.uids_run =
        "run":false
    localStorage.setItem("a_daren_list_run",JSON.stringify(Hs.uids_run))
    console.log "停止邀约"
Hs.start_run=()->
    Hs.uids_run =
        "run":true
    localStorage.setItem("a_daren_list_run",JSON.stringify(Hs.uids_run))
    console.log "开始邀约"
    Hs.jinritemai_yaoyue_run()

Hs.dom_insert_text =(current_dom,content)->
    current_dom.focus()
    current_dom.select()
    document.execCommand("inserttext",false, "")
    document.execCommand("inserttext",false, content)
Hs.next_yaoyue = ()->
    Hs.a_daren_list_nub+=1
    localStorage.setItem("a_daren_list_nub",Hs.a_daren_list_nub)
    _aim_link = "https://buyin.jinritemai.com/dashboard/servicehall/daren-profile?uid="+Hs.uids[Hs.a_daren_list_nub]
    window.location.href = _aim_link
Hs.jinritemai_yaoyue_run = ()->
    console.log "jinritemai_yaoyue_run run"
    console.log "邀约进行中"
    # 判断当前链接是不是要访问的链接
    if Hs.a_daren_list_nub >= Hs.uids.length
        Hs.stop_run()
        return
    _aim_link = "https://buyin.jinritemai.com/dashboard/servicehall/daren-profile?uid="+Hs.uids[Hs.a_daren_list_nub]
    if window.location.href != _aim_link
        window.location.href = _aim_link
        return
    # 点击报名招商
    Hs.show_info "加载等待6秒"
    await Hs.sleep 6000
    if $(".dp__action.dp__action-contact-online").text() in ["待处理"]
        Hs.next_yaoyue()
        return
    else if $(".dp__action.dp__action-contact-online").text() in ["报名招商"]
        if $(".dp__action.dp__action-contact-online").hasClass("daily-apply-todo-text-disabled")
            Hs.show_info "不能点击报名招商，数量用完"
            Hs.stop_run()
            return

        $(".dp__action.dp__action-contact-online").click()
        Hs.show_info "点击报名招商"
        await Hs.sleep 2000

        _current_fee_per_cent = parseInt($($(".dp__items>div>.dp__item-content")[1]).text())
        if isNaN(_current_fee_per_cent)
            _current_fee_per_cent = 0
        findmaster_goods_use_num = 0
        for _good in findmaster_goods
            if _good["fee_per_cent"]<_current_fee_per_cent
                continue
            $(".add-product-operate>button").click()
            Hs.show_info "点击添加商品"
            await Hs.sleep 1000
            Hs.dom_insert_text $("#product_name_or_id")[0],_good["good_id"]
            Hs.show_info "添加商品ID#{_good["good_id"]}"
            await Hs.sleep 2000
            # $(".auxo-table-cell.auxo-table-selection-column>div>label").click()
            $(".auxo-table-row.auxo-table-row-level-0>td>label").click()
            Hs.show_info "勾选"
            await Hs.sleep 2000
            findmaster_goods_use_num+=1
        if findmaster_goods_use_num == 0
            Hs.next_yaoyue()
            return

        console.log $(".add-product__footer-wrapper>div>button.auxo-btn.auxo-btn-primary")[0].disabled
        if $(".add-product__footer-wrapper>div>button.auxo-btn.auxo-btn-primary")[0].disabled
            Hs.next_yaoyue()
            return
        
        $(".add-product__footer-wrapper>div>button.auxo-btn.auxo-btn-primary").click()
        Hs.show_info "确认"
        await Hs.sleep 3000
        for _good in findmaster_goods
            if _good["fee_per_cent"]<_current_fee_per_cent
                continue
            if $("#cos_ratio_#{_good["good_id"]}").length==0
                continue
            Hs.dom_insert_text $("#cos_ratio_#{_good["good_id"]}")[0],_good["fee_per_cent"]
            Hs.show_info "更改佣金"
            await Hs.sleep 1000

        findmaster_people_num = parseInt(Math.random()*10%findmaster_people.length)
        Hs.show_info "联系人选择#{findmaster_people_num}"
        Hs.dom_insert_text $("#contact_name"),findmaster_people[findmaster_people_num]["name"]
        Hs.dom_insert_text $("#contact_mobile"),findmaster_people[findmaster_people_num]["mobilephone"]
        Hs.dom_insert_text $("#contact_wechat"),findmaster_people[findmaster_people_num]["wechat"]
        Hs.dom_insert_text $("#cooperation_desc"),findmaster_people[findmaster_people_num]["word"]
        await Hs.sleep 1000
        Hs.show_info "更改联系方式"
        $(".auxo-drawer-footer-buttons>.auxo-btn.auxo-btn-primary").click()
        Hs.show_info "提交报名"
        await Hs.sleep 3000
        Hs.next_yaoyue()
        return
    

$ ->
    console.log "This is Content Scripts index"
    $(window).on "load",(evt)->
        $("body").append """
        <style>
        #findmaster_jinritemai_yaoyue_btns>div{
            margin:10px 5px;
        }
        </style>
        <div style="position:fixed;right:10px;top:0px;z-index:9990;text-align:right;">
            <div id="findmaster_jinritemai_yaoyue_info" style="padding:5px 10px;background:rgba(0,0,0,0.8);color:white;">进展情况展示</div>
            <div id="findmaster_jinritemai_yaoyue_btns">

                <div><button id="findmaster_jinritemai_yaoyue_get_list">获取达人</button></div>
                <div><button id="findmaster_jinritemai_yaoyue_stop_list">停止拉取</button></div>
                <div><button id="findmaster_jinritemai_yaoyue_start">开始邀约</button></div>
                <div><button id="findmaster_jinritemai_yaoyue_stop">停止邀约</button></div>
            </div>
        </div>
        """
        if Hs.uids_run["run"]
            setTimeout ()->
                Hs.jinritemai_yaoyue_run()
            ,2000
    $("body").on "click","#findmaster_jinritemai_yaoyue_get_list",()->
        Hs.get_list()
    $("body").on "click","#findmaster_jinritemai_yaoyue_stop_list",()->
        Hs.stop_list()
    $("body").on "click","#findmaster_jinritemai_yaoyue_stop",()->
        Hs.stop_run()
    $("body").on "click","#findmaster_jinritemai_yaoyue_start",()->
        Hs.start_run()




