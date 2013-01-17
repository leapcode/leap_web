function(doc) {
  if (doc.type != 'User') {
    return;
  }
  emit(doc.login, 1);
  doc.email_aliases.forEach(function(alias){
    emit(alias.username, 1);
  });
}
