module RequestHelper
  def accept_message(request)
    "By pressing OK, I affirm that I am #{current_user.full_name}, the intended recipient of #{request.user.full_name}'s vaccination record."
  end
end
