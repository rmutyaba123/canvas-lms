/*
 * Copyright (C) 2017 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that they will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import React, {Component} from 'react'
import {themeable} from '@instructure/ui-themeable'
import moment from 'moment-timezone'
import {IconButton} from '@instructure/ui-buttons'
import {Pill} from '@instructure/ui-pill'
import {Link} from '@instructure/ui-link'
import {PresentationContent, ScreenReaderContent} from '@instructure/ui-a11y-content'
import {IconXLine} from '@instructure/ui-icons'
import {string, bool, number, func, object} from 'prop-types'
import {getFullDateAndTime} from '../../utilities/dateUtils'
import formatMessage from '../../format-message'
import {animatable} from '../../dynamic-ui'
import styles from './styles.css'
import theme from './theme'

export class Opportunity extends Component {
  static propTypes = {
    id: string.isRequired,
    dueAt: string.isRequired,
    points: number,
    courseName: string.isRequired,
    opportunityTitle: string.isRequired,
    timeZone: string.isRequired,
    url: string.isRequired,
    dismiss: func,
    plannerOverride: object,
    registerAnimatable: func,
    deregisterAnimatable: func,
    animatableIndex: number,
    isObserving: bool
  }

  constructor(props) {
    super(props)

    const tzMomentizedDate = moment.tz(props.dueAt, props.timeZone)
    this.fullDate = getFullDateAndTime(tzMomentizedDate)
  }

  static defaultProps = {
    registerAnimatable: () => {},
    deregisterAnimatable: () => {},
    dismiss: () => {}
  }

  componentDidMount() {
    this.props.registerAnimatable('opportunity', this, this.props.animatableIndex, [this.props.id])
  }

  UNSAFE_componentWillReceiveProps(newProps) {
    this.props.deregisterAnimatable('opportunity', this, [this.props.id])
    this.props.registerAnimatable('opportunity', this, newProps.animatableIndex, [newProps.id])
  }

  componentWillUnmount() {
    this.props.deregisterAnimatable('opportunity', this, [this.props.id])
  }

  linkRef = ref => {
    this.link = ref
  }

  getFocusable() {
    return this.link
  }

  dismiss = () => {
    if (this.props.dismiss) {
      this.props.dismiss(this.props.id, this.props.plannerOverride)
    }
  }

  renderButton() {
    const isDismissed = this.props.plannerOverride && this.props.plannerOverride.dismissed
    return (
      <div className={styles.close}>
        {isDismissed || this.props.isObserving ? null : (
          <IconButton
            onClick={this.dismiss}
            renderIcon={IconXLine}
            withBorder={false}
            withBackground={false}
            size="small"
            screenReaderLabel={formatMessage('Dismiss {opportunityName}', {
              opportunityName: this.props.opportunityTitle
            })}
          />
        )}
      </div>
    )
  }

  renderPoints() {
    if (typeof this.props.points !== 'number') {
      return (
        <ScreenReaderContent>
          {formatMessage('There are no points associated with this item')}
        </ScreenReaderContent>
      )
    }
    return (
      <div className={styles.points}>
        <ScreenReaderContent>
          {formatMessage('{points} points', {points: this.props.points})}
        </ScreenReaderContent>
        <PresentationContent>
          <span className={styles.pointsNumber}>{this.props.points}</span>
          {formatMessage('points')}
        </PresentationContent>
      </div>
    )
  }

  render() {
    return (
      <div className={styles.root}>
        <div className={styles.oppNameAndTitle}>
          <div className={styles.oppName}>{this.props.courseName}</div>
          <div className={styles.title}>
            <Link
              isWithinText={false}
              theme={{mediumPaddingHorizontal: '0', mediumHeight: 'normal'}}
              href={this.props.url}
              elementRef={this.linkRef}
            >
              {this.props.opportunityTitle}
            </Link>
          </div>
        </div>
        <div className={styles.footer}>
          <div className={styles.status}>
            <Pill color="danger">{formatMessage('Missing')}</Pill>
            <div className={styles.due}>
              <span className={styles.dueText}>{formatMessage('Due:')}</span> {this.fullDate}
            </div>
          </div>
          {this.renderPoints()}
        </div>
        {this.renderButton()}
      </div>
    )
  }
}

export default animatable(themeable(theme, styles)(Opportunity))
