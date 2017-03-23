
//
// add a bootstrap alert to the page via javascript.
//
function alert_message(msg) {
  $('#messages').append('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a><pre>'+msg+'</pre></div>');
}

ClientSideValidations.formBuilders['SimpleForm::FormBuilder'].wrappers.bootstrap = ClientSideValidations.formBuilders['SimpleForm::FormBuilder'].wrappers["default"];
