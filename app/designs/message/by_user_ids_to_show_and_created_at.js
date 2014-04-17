// not using at moment
// call with something like Message.by_user_ids_to_show_and_created_at.startkey([user_id, start_date]).endkey([user_id,end_date])
function (doc) {
  if (doc.type === 'Message' && doc.user_ids_to_show && Array.isArray(doc.user_ids_to_show)) {
    doc.user_ids_to_show.forEach(function (userId) {
      emit([userId, doc.created_at], 1);
    });
  }
}
