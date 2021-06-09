module RequestHelper
  def accept_message(request)
    "By pressing Ok, I affirm that I am #{current_user.full_name}, the intended recipient of #{request.data}'s vaccination record."
  end
end
