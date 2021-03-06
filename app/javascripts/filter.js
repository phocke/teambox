Filter = {
  assigned_options: null,
  count_due_date: null,
  
  init: function() {
    var filter_assigned = $("filter_assigned");
    var filter_due_date = $("filter_due_date");
    if (filter_assigned)
      Filter.assigned_options = Filter.initOptions(filter_assigned.options);
    if (filter_due_date)
      Filter.count_due_date = Filter.mapOptions(filter_due_date.options);
  },
  
  showAllTaskLists: function() {
    $$(".task_list_container").each(function(e){ e.show() })
  },
  showAllTasks: function() {
    $$(".tasks div.task").each(function(e){ e.show() });
    $$(".tasks.closed div.task").each(function(e){ e.show() });
  },
  hideAllTasks: function() {
    $$(".tasks div.task").each(function(e){ e.hide() });
    $$(".tasks.closed div.task").each(function(e){ e.hide() });
  },
  showTasks: function(by, filter) {
    $$(".tasks.open div." + by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        e.show();
      else
        e.hide();
    });
  },
  countTasks: function(by, filter) {
    var count = 0;
    $$(".tasks.open div." + by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        count += 1;
    });
    return count;
  },
  hideTasks: function(by, filter) {
    $$("table.task_list div.task" + by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        e.hide();
      else
        e.show();
    });
  },
  // Hides task lists if they don't have any visible tasks
  foldEmptyTaskLists: function() {
    $$("div.task_list").each(function(e) {
      var container = e.up('.task_list_container');
      if (container.hasClassName('archived'))
      {
        container.hide();
        return;
      }

      visible_tasks = e.select(".task").reject( function(e) {
        return e.getStyle("display") == "none";
      })
      if(visible_tasks.length == 0) {
        container.hide();
      }
    })
  },
  
  initOptions: function(assigned_options) {
    var out = [];
    len = assigned_options.length;
    for (var i=0; i<len; i++) {
        var option = assigned_options[i];
        out.push({value:option.value, text:option.text, disabled:option.disabled, count:0});
    };
    return out;
  },
  
  mapOptions: function(options) {
      var out = [];
      var len = options.length;
      for (var i=0; i<len; i++)
        out.push(options[i].text);
      return out;
  },
  
  updateFilters: function() {
    if (Filter.assigned_options == null && Filter.count_due_date == null)
      Filter.init();
    
    var el = $("filter_assigned");
    var el_filter = $("filter_due_date");
    if (el == null)
      return;

    var assigned = el.value == 'all' ? 'task' : el.value;
    var filter = el_filter.value == 'all' ? null : el_filter.value;

    //console.log("FILTER:" + assigned + "," + filter);
    
    Filter.showAllTaskLists();
    Filter.hideAllTasks();

    if (assigned == 'task' && filter == null) 
    {
      Filter.showAllTasks();
    }
    else
    {
      Filter.showTasks(assigned, filter);
      Filter.foldEmptyTaskLists();
    }

    Filter.updateCounts(true);
  },

  updateCounts: function(due_only) {
    if (Filter.assigned_options == null && Filter.count_due_date == null)
      Filter.init();

    var el = $("filter_assigned");
    var el_filter = $("filter_due_date");
    if (el == null)
      return;
    
    var current_assigned = el.value;
    var assigned = el.value == 'all' ? 'task' : el.value;
    var count_due_date = Filter.count_due_date;
    var assigned_options = Filter.assigned_options;
    var len;
    
    if (!due_only) 
    {
      el.options.length = 0;
      len = assigned_options.length;
      var idx = 0;
      for (var i=0; i<len; i++)
      {
        var option = assigned_options[i];
        if (option.disabled) {
            el.options[idx] = new Option(option.text, option.value);
            el.options[idx].disabled = true;
            idx += 1;
        } else {
            var filter = option.value == 'all' ? 'task' : option.value;
            var count = Filter.countTasks(filter, null);
            if (i < 3 || count > 0 || filter == current_assigned) {
                el.options[idx] = (new Option(option.text + ' (' + count + ')', filter));
                idx += 1;
            }
        }
      }
      el.value = current_assigned;
    }

    len = el_filter.options.length;
    for (var i=0; i<len; i++)
    {
      var option = el_filter.options[i];
      if (option.disabled)
        continue;
      var filter = option.value == 'all' ? null : option.value;
      option.text = count_due_date[i] + ' (' + Filter.countTasks(assigned, filter) + ')';
    }
  }
};

document.on("change", "#filter_assigned", function(evt, el){
  Filter.updateFilters();
});

document.on("change", "#filter_due_date", function(evt, el){
  Filter.updateFilters();
});

document.on('dom:loaded', function() {
  Filter.updateCounts(false);
});
