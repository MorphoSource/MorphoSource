// Enable/Disable the Add User button when sharing a collection
import CollectionsV2 from 'hyrax/collections_v2'
import CollectionUtilities from 'hyrax/collections_utils';

export default class MorphosourceCollectionsV2 extends CollectionsV2 {

  constructor() {
    super();
    this.sharingAddUserButtonDisabler();
    this.sharingAddGroupButtonDisabler();
  }

  sharingAddUserButtonDisabler() {
    const { addParticipantsInputValidator } = this.collectionUtilities;
    // Selector for the button to enable/disable
    const buttonSelector = '.edit-collection-add-user-sharing-button';
    const inputsWrapper = '.form-add-user-sharing-wrapper';

    $('#participants')
      .find(inputsWrapper)
      .on(
        'change',
        // custom data we need passed into the event handler
        {
          buttonSelector: '.edit-collection-add-user-sharing-button',
          inputsWrapper
        },
        addParticipantsInputValidator.handleWrapperContentsChange.bind(
          addParticipantsInputValidator
        )
      );
  }

  sharingAddGroupButtonDisabler() {
    const { addParticipantsInputValidator } = this.collectionUtilities;
    // Selector for the button to enable/disable
    const buttonSelector = '.edit-collection-add-group-sharing-button';
    const inputsWrapper = '.form-add-group-sharing-wrapper';

    $('#participants')
      .find(inputsWrapper)
      .on(
        'change',
        // custom data we need passed into the event handler
        {
          buttonSelector: '.edit-collection-add-group-sharing-button',
          inputsWrapper
        },
        addParticipantsInputValidator.handleWrapperContentsChange.bind(
          addParticipantsInputValidator
        )
      );
  }
}
