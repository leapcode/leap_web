function (doc) {
  if ((doc['type'] == 'User') && (doc['created_at'] != null) && (doc['one_month_warning_sent'] == null)) {
    emit(doc['created_at'], 1);
  }    
}
