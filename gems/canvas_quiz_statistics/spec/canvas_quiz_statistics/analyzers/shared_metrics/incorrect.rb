# frozen_string_literal: true

#
# Copyright (C) 2014 - present Instructure, Inc.
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

shared_examples "[:incorrect]" do
  it "counts all incorrect responses" do
    stats = subject.run([
                          { correct: "true" },
                          { correct: true },
                          { correct: "false" },
                          { correct: false },
                          { correct: nil },
                          { correct: "partial" },
                          { correct: "undefined" },
                          { correct: "defined" }
                        ])

    expect(stats[:incorrect]).to eq(3)
  end
end
