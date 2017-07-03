// import React, { Component } from "react";
// import ReactDOM from "react-dom";
import moment from "moment";
import Datetime from 'react-datetime';
require('moment/locale/ru');

class ParamsForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      calcDate: this.props.calcDate
    };
    this.onChange = this.onChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleDateChange = this.handleDateChange.bind(this);
  }
  handleDateChange(e) {
    this.setState({calcDate: e.target.value});
  }
  handleSubmit(e) {
    e.preventDefault();
    var calcDate = this.state.calcDate.trim();
    if (!calcDate) { 
      return;
    }
    this.props.onParamsSubmit({calcDate: calcDate});
  }
  onChange(event) {
    var calcDate = event.format("YYYY.MM.DD");
    this.setState({calcDate: calcDate});
  }
  render() {
    return (
    <div className="col-md-12">
      <form className="form-group" onSubmit={this.handleSubmit}>
          <Datetime 
            locale="ru" 
            timeFormat={false} 
            input={false}
            onChange={this.onChange}
          />
        <input
          type="text"
          value={this.state.calcDate}
          readOnly={true}
          onChange={this.handleDateChange}
        />
        <input type="submit" value="Пересчитать" />
      </form>
    </div>
    );
  }
}

class TempRow extends React.Component{
  render() {
    var stations = {34622: "Амвросиевка", 34524: "Дебальцево", 34519: "Донецк", 34615: "Волноваха", 34712: "Мариуполь"};
    var style = {
      backgroundColor: '#ddd',
      textAlign: "center",
      width: '70px'
    };
    var v = [];
    for(var i=0;i<9;i++){
      v.push(<td style={(i % 2 == 0) ? style : {textAlign: "center", width: '70px'}} key={i.toString()}>{this.props.vector[i]}</td>);
      
    };

    return (
      <tr>
        <td>{stations[this.props.station]}</td>
        {v}
      </tr>
    );
  }
}

class TemperaturesTable extends React.Component{
  render() {
    var rows = [];
    var temps;
    
    temps = this.props.temperatures;
    
    ['34622', '34524', '34519', '34615', '34712'].forEach(function(s) {
      rows.push(<TempRow station={s} vector={[temps[s+'-09'], temps[s+'-12'], temps[s+'-15'], temps[s+'-18'], temps[s+'-21'], temps[s+'-00'], temps[s+'-03'], temps[s+'-06'], temps[s+'-99']]} key={s}/>);
    });
  
    return (
      <table className = "table table-hover">
        <thead>
          <tr>
            <th>Метеостанция</th>
            <th>09</th>
            <th>12</th>
            <th>15</th>
            <th>18</th>
            <th>21</th>
            <th>00</th>
            <th>03</th>
            <th>06</th>
            <th>Средняя</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}


class TemperaturesShow extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      value: new Date(),
      calcDate: this.props.calcDate,
      temperatures: this.props.temperatures
    };
    this.handleParamsSubmit = this.handleParamsSubmit.bind(this);
    this.handleDateChange = this.handleDateChange.bind(this);
  }

  handleParamsSubmit(params) {
    $.ajax({
      type: 'GET',
      url: "get_temps?calc_date="+params.calcDate
      }).done(function(data) {
        this.setState({
          calcDate: data.calcDate,
          temperatures: data.temps
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  
  
  handleDateChange(e) {
    var d = e.target.value;
  }

  render(){
    return(
      <div className="col-md-6 col-md-offset-3">
        <h1>К договору №08/16-17/03   ГП "Донбасстеплоэнерго"   тел. 304-74-24</h1>
        <ParamsForm calcDate={this.state.calcDate} onParamsSubmit={this.handleParamsSubmit} />
        <h4>Данные за {this.state.calcDate}</h4>
        <TemperaturesTable temperatures={this.state.temperatures} />
      </div>
    );
  }
}

export default TemperaturesShow;