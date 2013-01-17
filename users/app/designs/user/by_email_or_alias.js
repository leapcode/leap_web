function(doc) {
  if (doc.type != 'User') {
    return;
  }
  if (doc.email) {
    emit(doc.email, 1);
  }
  doc.email_aliases.forEach(function(alias){
    emit(alias.email, 1);
  });
}
