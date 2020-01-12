
class SuggestionInputsController < ApplicationController

  before_filter :signed_in_user
  before_filter :active_user

  
  def new
    @existing_suggestion = current_user.suggestion_inputs.find_by_suggestion_id(params[:suggestion_id])

    if @existing_suggestion.nil?
      if params.has_key?(:want)
        SuggestionInput.create(:suggestion_id => params[:suggestion_id], :user_id => current_user.id, :want => params[:want])
        flash[:success] = "Thank you for voting! The feature with the most votes will be the next thing on our list."
        
        if params.has_key?(:other_vote_suggestion_id)
          @other_suggestion = current_user.suggestion_inputs.find_by_suggestion_id(params[:other_vote_suggestion_id])
          @other_suggestion.destroy
        end  
      else
        SuggestionInput.create(:suggestion_id => params[:suggestion_id], :user_id => current_user.id, :like_vote => params[:like])
        flash[:success] = "Thank you for providing us feedback. We really appreciate it!"
      end
    else
      if params.has_key?(:want) 
        @existing_suggestion.update_attribute(:want, params[:want])  
        flash[:success] = "Thank you for voting! The feature with the most votes will be the next thing on our list."
      else
        @existing_suggestion.update_attribute(:like_vote, params[:like])  
        flash[:success] = "Thank you for providing us feedback. We really appreciate it!"
      end
    end

    redirect_to root_path
  end
end
