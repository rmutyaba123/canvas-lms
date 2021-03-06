# frozen_string_literal: true

#
# Copyright (C) 2016 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

describe SupportHelpers::TurnitinController do
  describe "require_site_admin" do
    it "redirects to root url if current user is not a site admin" do
      account_admin_user
      user_session(@user)
      get :shard
      assert_unauthorized
    end

    it "redirects to login if current user is not logged in" do
      get :shard
      assert_unauthorized
    end

    it "renders 200 if current user is a site admin" do
      site_admin_user
      user_session(@user)
      get :shard
      assert_status(200)
    end
  end

  describe "helper action" do
    before do
      site_admin_user
      user_session(@user)
    end

    context "md5" do
      it "creates a new MD5Fixer" do
        fixer(SupportHelpers::Tii::MD5Fixer)
        get :md5
        expect(response.body).to eq("Enqueued TurnItIn MD5Fixer ##{@fixer.job_id}...")
      end
    end

    context "error2305" do
      it "creates a new Error2305Fixer" do
        fixer(SupportHelpers::Tii::Error2305Fixer)
        get :error2305
        expect(response.body).to eq("Enqueued TurnItIn Error2305Fixer ##{@fixer.job_id}...")
      end
    end

    context "shard" do
      it "creates a new ShardFixer" do
        fixer(SupportHelpers::Tii::ShardFixer)
        get :shard
        expect(response.body).to eq("Enqueued TurnItIn ShardFixer ##{@fixer.job_id}...")
      end

      it "creates a new ShardFixer with after_time" do
        fixer = SupportHelpers::Tii::ShardFixer.new(@user.email, "2016-05-01")
        expect(SupportHelpers::Tii::ShardFixer).to receive(:new)
          .with(@user.email, Time.zone.parse("2016-05-01")).and_return(fixer)
        expect(fixer).to receive(:monitor_and_fix)
        get :shard, params: { after_time: "2016-05-01" }
        expect(response.body).to eq("Enqueued TurnItIn ShardFixer ##{fixer.job_id}...")
      end
    end

    context "assignment" do
      it "creates a new AssignmentFixer with id" do
        assignment_model
        fixer = SupportHelpers::Tii::AssignmentFixer.new(@user.email, nil, @assignment.id)
        expect(SupportHelpers::Tii::AssignmentFixer).to receive(:new).with(@user.email, nil, @assignment.id).and_return(fixer)
        expect(fixer).to receive(:monitor_and_fix)
        get :assignment, params: { id: @assignment.id }
        expect(response.body).to eq("Enqueued TurnItIn AssignmentFixer ##{fixer.job_id}...")
      end

      it "returns 400 status without id" do
        expect(SupportHelpers::Tii::AssignmentFixer).not_to receive(:new)
        get :assignment
        expect(response.body).to eq("Missing assignment `id` parameter")
        assert_status(400)
      end
    end

    context "refresh_lti_attachment" do
      it "creates a new RefreshLtiAttachmentFixter" do
        submission_model
        attachment_model
        fixer = SupportHelpers::Tii::LtiAttachmentFixer.new(@user.email, nil, @submission.id, @attachment.id)
        expect(SupportHelpers::Tii::LtiAttachmentFixer).to receive(:new)
          .with(@user.email, nil, @submission.id, @attachment.id).and_return(fixer)
        expect(fixer).to receive(:monitor_and_fix)
        get :lti_attachment, params: { submission_id: @submission.id, attachment_id: @attachment.id }
        expect(response.body).to eq("Enqueued TurnItIn LtiAttachmentFixer ##{fixer.job_id}...")
      end
    end

    context "pending" do
      it "creates a new StuckInPendingFixer" do
        fixer(SupportHelpers::Tii::StuckInPendingFixer)
        get :pending
        expect(response.body).to eq("Enqueued TurnItIn StuckInPendingFixer ##{@fixer.job_id}...")
      end
    end

    context "expired" do
      it "creates a new ExpiredAccountFixer" do
        fixer(SupportHelpers::Tii::ExpiredAccountFixer)
        get :expired
        expect(response.body).to eq("Enqueued TurnItIn ExpiredAccountFixer ##{@fixer.job_id}...")
      end
    end
  end

  def fixer(klass)
    @fixer = klass.new(@user.email)
    expect(klass).to receive(:new).with(@user.email, nil).and_return(@fixer)
    expect(@fixer).to receive(:monitor_and_fix)
    @fixer
  end
end
