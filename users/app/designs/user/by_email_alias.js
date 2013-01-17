function(doc) {
  if (doc.type != 'User') {
    return;
  }
  doc.email_aliases.forEach(function(alias){
    emit(alias.email, 1);
  });
}
