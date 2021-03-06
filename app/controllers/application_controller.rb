# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
 
  # AuthenticationSystem supports the acts_as_authenticated
  include AuthenticatedSystem

  filter_parameter_logging :password

  # "remember me" functionality
  before_filter :login_from_cookie

  before_filter :login_required

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery
  
  protected

  # Set the last selected vendor by id. The value is saved in the session.
  #
  # This method is used by TestPlan#create to retain previous selections as a convenience
  # in the UI.
  def last_selected_vendor_id=(vendor_id)
    session[:previous_vendor_id] = vendor_id
  end

  # Get the last selected vendor from the session.
  def last_selected_vendor
    begin
      Vendor.find_by_id(session[:previous_vendor_id]) if session[:previous_vendor_id]
    rescue ActiveRecord::StatementInvalid
    end
  end

  # Set the page title for the controller, can be overridden by calling page_title in any controller action.
  def self.page_title(title)
    class_eval %{
      before_filter :set_page_title
      def set_page_title
        @page_title = %{#{title}}
      end
    }
  end

  # Set the page title for the current action.
  def page_title(title)
    @page_title = title
  end

  def require_administrator
    if current_user.try(:administrator?)
      true
    else
      redirect_to test_plans_url
      false
    end
  end

  def rescue_action_in_public(exception)
    if request.xhr?
      render :update, :status => '500' do |page|
        page.alert("An internal error occurred, please report this to #{FEEDBACK_EMAIL}.")
      end
    else
      render :status => '500', :template => "rescues/error", :layout => false
    end
  end

  #def log_error(exception) 
  #  super(exception)
  #  begin
  #    logger.error("Attempting to send error email")
  #    ErrorMailer.deliver_errormail(exception, 
  #     clean_backtrace(exception), 
  #      session.instance_variable_get("@data"), 
  #      params,
  #      request.env)
  #  rescue => e
  #    logger.error("Failed to send error email")
  #    logger.error(e)
  #  end
  #end
  
end
