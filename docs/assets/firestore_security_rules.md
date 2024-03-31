```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if true;
    }
    match /clubs/{clubId} {
      // Return true if the user is removing himself from the room.
      function isLeaving() {
        return onlyRemoving('users', request.auth.uid);
      }

      // Return true if the user is adding himself to the room.
      function isJoining() {
        return
          onlyAddingOneElement('users')
          && 
          request.resource.data.users.toSet().difference(resource.data.users.toSet()) == [request.auth.uid].toSet();
      }
      allow read: if true;
      allow create: if (request.resource.data.uid == request.auth.uid);
      allow update: if (resource.data.uid == request.auth.uid) || isJoining() || isLeaving();
    }
  }
}

// Return true if the array field in the document is removing only the the element. It must maintain other elements.
//
// arrayField is an array
// [element] is an element to be removed from the arrayField
//
// Returns
// - true if it try to remove an element that is not existing int the array and no other fields are changed.
// - false if the document does not exsit (especially when you put it on "update if: ...").
// 
// Use case;
// Other users can add or remove only their uid from the followers array of the otehr user document
// match /users/{documentId} {
//   allow update: if request.auth.uid == documentId || onlyAdding('followers', request.auth.uid) || onlyRemoving('followers', request.auth.uid)
// }
function onlyRemoving(arrayField, element) {

  let oldSet = (arrayField in resource.data ? resource.data[arrayField] : []).toSet();
  let newSet = request.resource.data[arrayField].toSet();

  return
      // If the field does not exist and no other except the field changes, return true.
      // Why? - preventing permission if it tries to remove somthing that does not exist.
      // Does - it jsut return true without producing permission error.
      // Result - when something is deleted from non exisiting array, just pass.
      ( !(arrayField in resource.data) && noFieldChangedExcept(arrayField) )
      ||
      // If the field exists but the element does not exists.
      // Why? - when something is delete when it is not existing, just pass without permission error.
      ( !(element in oldSet) && noFieldChanged() )
      ||
      (
        // If the "arrayField" is the only field that is being chagned,
        onlyUpdating([arrayField])
        &&
        // And if the "element" is the only element that is being removed.
        oldSet.difference(newSet) == [element].toSet()
        &&
        // And if the old set is same as new set meaning, when something is deleted, the old set without the deleted element must have same value with new set.
        oldSet.intersection(newSet) == newSet
      )
  ;
}


// Returns true if it adds only one element to the array field.
//
// * It allows to update other fields in the document.
//
// This must add an elemnt only. Not replacing any other element. It does unique element check.
function onlyAddingOneElement(arrayField) {
  return
    resource.data[arrayField].toSet().intersection(request.resource.data[arrayField].toSet()) == resource.data[arrayField].toSet()
    &&
    request.resource.data[arrayField].toSet().difference(resource.data[arrayField].toSet()).size() == 1
  ;
}

// Returns true if there is no fields that are updated except the specified field.
function noFieldChangedExcept(field) {
  return request.resource.data.diff(resource.data).affectedKeys().hasOnly([field]);
}

// Returns true if there is no fields that are updated.
function noFieldChanged() {
  return request.resource.data.diff(resource.data).affectedKeys().hasOnly([]);
}

// Returns true if only the specified fields are updated in the document.
//
// For instance, the input fields are ['A', 'B'] and if the document is updated with ['A', 'C'], then it return true.
// For instance, the input fields are ['A', 'B'] and if the document is updated with ['C', 'D'], then it return false.
function onlyUpdating(fields) {
  return request.resource.data.diff(resource.data).affectedKeys().hasOnly(fields);
}
```
