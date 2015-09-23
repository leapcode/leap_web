class SubscriptionsController < BillingBaseController

before_filter :require_admin
before_filter :require_login
before_filter :confirm_cancel_subscription, :only => [:destroy]
before_filter :confirm_no_pending_active_pastdue_subscription, :only => [:new, :create]
before_filter :confirm_self, :only => [:new, :create]
