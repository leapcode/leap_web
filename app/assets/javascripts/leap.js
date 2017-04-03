
//
// add a bootstrap alert to the page via javascript.
//
function alert_message(msg) {
  $('#messages').append('<div class="alert alert-danger"><a class="close" data-dismiss="alert">×</a>'+msg+'</div>');
}

ClientSideValidations.formBuilders['SimpleForm::FormBuilder'].wrappers.bootstrap = ClientSideValidations.formBuilders['SimpleForm::FormBuilder'].wrappers["default"];
