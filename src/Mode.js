import React from 'react';

class Mode extends React.Component {
    render() {
        return (
            <button className="mode" onClick={this.props.onClick}>
                {this.props.value !== '#' ? 'X': '#'}
            </button>
        );
    }
}

export default Mode;