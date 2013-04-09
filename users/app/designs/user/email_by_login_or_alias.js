function(doc) {
  if (doc.type != 'User') {
    return;
  }
  emit(doc.login, doc.public_key);
  doc.email_aliases.forEach(function(alias){
    emit(alias.username, doc.public_key);
  });
}
