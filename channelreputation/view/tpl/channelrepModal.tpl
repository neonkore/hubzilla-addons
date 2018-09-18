<!-- Modal -->
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="channelrepModalLabel">Channel Reputation</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="channelrepSecurityToken" name="form_security_token" value="{{$security_token}}">
        <input type="hidden" id="channelrepId" name="channelrepId" value="{{$channelrepId}}">
        <input type="hidden" id="channelrepUid" name="channelrepUid" value="{{$uid}}">
        <h5 class="modal-title" id="channelrePointsLabel">Vote weight (Max: {{$maxpoints}})</h5>
        <input type="text" id="channelrepPoints" name="channelrepPoints" value="{{$pointssuggestion}}">
        <button type="button" class="channelrepAdd" aria-hidden="true" onClick="channelrepPlus();">Upvote</button>
        <button type="button" class="channelrepSubtract" aria-hidden="true" onClick="channelrepMinus();">Downvote</button>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>