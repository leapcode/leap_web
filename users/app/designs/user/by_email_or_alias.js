function(doc) {
  if (doc.type != 'User') {
    return;
  }
  if (doc.email) {
    emit(doc.email, doc);
  }
  doc.email_aliases.forEach(function(alias){
    emit(alias.email, doc);
  });
}
