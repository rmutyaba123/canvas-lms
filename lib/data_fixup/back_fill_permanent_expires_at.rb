# frozen_string_literal: true

# Copyright (C) 2021 - present Instructure, Inc.
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

module DataFixup
  module BackFillPermanentExpiresAt
    class << self
      def run
        dks = DeveloperKey.where(auto_expire_tokens: false).find_by(id: AccessToken.distinct_values(:developer_key_id))
        AccessToken.find_ids_in_batches do |batch|
          AccessToken.where(id: batch, developer_key_id: dks.map(&:id) + [nil], permanent_expires_at: nil)
            .where.not(expires_at: nil)
            .update_all("permanent_expires_at=expires_at, expires_at=NULL")
        end
      end
    end
  end
end
