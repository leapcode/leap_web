
//
// add a bootstrap alert to the page via javascript.
//
function alert_message(msg) {
  $('#messages').append('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a><span>'+msg+'</span></div>');
}
