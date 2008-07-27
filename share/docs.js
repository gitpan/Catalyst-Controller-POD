Ext.namespace("POD");

POD.addTab = function (title, url, section,module) {
	if(Ext.getCmp("tab-"+title)) {
		Ext.getCmp("tab-"+title).show();
		return Ext.getCmp("tab-"+title);
	}
	var tab = POD.tabs.add({
		title: title, 
		id: "tab-" + title,
		closable: true,
		closeAction: "hide",
		autoLoad: {url : url, callback : function() {POD.scrollToSection(tab, section,module);}},
		autoScroll: true
		}
	);
	tab.show();
	return tab;
	
}

POD.proxyLink = function(link) {
	var re = new RegExp("^" + Ext.escapeRe("[% root %]"));
	if(!re.test(link.href)) return true;
	var module = link.href.replace(new RegExp(Ext.escapeRe("[% root %]/module/")), "");
	
		var parts = module.split(/#/);
		section = parts[1];
		module = parts[0];
		if(module == "[% root %]/") {
			module = POD.tabs.getActiveTab().getId().replace(/tab-/, "");
		}
	//module = POD.tabs.getActiveTab().getId();
	var tab = POD.addTab(module, link.href, section, module);
	POD.scrollToSection(tab, section, module);
	return false;
	
}

POD.scrollToSection = function(tab, section,module){
	var el = document.getElementById("section-"+module+"-"+section);
	if(el){
		var top = (Ext.fly(el).getOffsetsTo(tab.body)[1]) + tab.body.dom.scrollTop;
		tab.body.scrollTo('top', top, {duration:.5});
    }
}

POD.filterTree = function (e){
	var text = e.target.value;
	var filter = POD.filter;
	var tree = POD.tree;
	if(!text){
		filter.clear();
		return;
	}
	tree.expandAll();
	
	var re = new RegExp('^' + Ext.escapeRe(text), 'i');
	filter.filterBy(function(n){
		return re.test(n.attributes.name);
	});
	
}


Ext.onReady(function(){
	var tree = new Ext.tree.TreePanel({
		title: "Gruppen",
		autoScroll:true,
		width: 250,
		collapsible:true,
		animate:true,
		rootVisible: false,
		split: true,
		region: "west",
	containerScroll: true,
	listeners:  {
		"click" : function(node) { POD.addTab(node.attributes.name, "[% root %]/module/"+node.attributes.name) }},
	loader: new Ext.tree.TreeLoader({
		dataUrl:'[% root %]/modules',
		preloadChildren: true,
		clearOnLoad: false

	}),
	tbar: [new Ext.form.TextField({
		width: 200,
		emptyText:'Find a Class',
		listeners:{
			render: function(f){
				f.el.on('keydown', POD.filterTree, f, {buffer: 350});
			}
		}
	}), ' ', ' ',{
	 	   handler: function (){tree.expandAll()},
	 	   tooltip: 'Expand all nodes',
	 	   iconCls:".icon-expand-all"},
	 	  {
	 	 	   handler: function (){tree.collapseAll()},
	 	 	   tooltip: 'Collapse all nodes',
	 	 	   iconCls:".icon-collapse-all"}
     ]
	}) ;
	var root = new Ext.tree.AsyncTreeNode({
		text: 'Patientengruppen',
		expanded:true,
		//id:'root',
	});

	tree.setRootNode(root);
	POD.tree = tree;
	POD.filter = new Ext.tree.TreeFilter(tree, {
		clearBlank: true,
		autoClear: true
	});


	new Ext.tree.TreeSorter(tree,{});
	
	var tabs = 
        new Ext.TabPanel({
            region:'center',
            activeTab:0,
            autoScroll: true,
            margins: "5 5 5 5",
            enableTabScroll: true,
            items: {
				layout :'fit',
	            title : "Home",
	            id : "search-box",
				frame :false,
				border :false,
					html :"<div style=\"width:330px;\" class='x-box-blue'> "
							+ "<div class=\"x-box-tl\"><div class=\"x-box-tr\"><div class=\"x-box-tc\"></div></div></div> "
							+ "<div class=\"x-box-ml\"><div class=\"x-box-mr\"><div class=\"x-box-mc\"> "
							+ "<h3 style=\"margin-bottom:5px;\">Search</h3> "
							+ " <input type=\"text\" size=\"21\" name=\"search\" id=\"search\" class=\"x-form-text\" style='font-size: 20px; height: 31px'/>"
							+ " <div style=\"padding-top:4px;\">Type at least three characters</div>"
							+ " </div></div></div>"
							+ " <div class=\"x-box-bl\"><div class=\"x-box-br\"><div class=\"x-box-bc\"></div></div></div>"
							+ "</div>"
				}
        });
	

	POD.tabs = tabs;
	
    var viewport = new Ext.Viewport({
        layout:'border',
        items:[tabs, tree
         ]
    });
    
	Ext.getCmp('search-box').getEl().alignTo('north', 'tl-c', [-165,-45]);

    	
});