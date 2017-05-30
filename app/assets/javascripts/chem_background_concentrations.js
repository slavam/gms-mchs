// import React from "react";
const React = require("react");
// import Datetime from 'react-datetime';
// //require('react-datetime');
// require('moment/locale/ru');
class ChemOptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      defaultValue: this.props.defaultValue
    };
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    var name = this.props.name;
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.state.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={name == "selectStation"? op.idstation : op.idsubstance} value={name == "selectStation"? op.idstation : op.idsubstance}>{op.description}</option>;
        })
      }
    </select>;
  }
}

class BCParams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      startDate: this.props.startDate,
      endDate: this.props.endDate,
      siteIndex: 1,
      substanceIndex: 1,
      month: this.props.month,
      year: this.props.year
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.onStartChange = this.onStartChange.bind(this);
    this.onEndChange = this.onEndChange.bind(this);
    this.startDateChange = this.startDateChange.bind(this);
    this.endDateChange = this.endDateChange.bind(this);
  }
  handleSubmit(e) {
    e.preventDefault();
    var site = this.state.siteIndex;
    var substance = this.state.substanceIndex;
    var startDate = this.state.startDate.trim();
    var endDate = this.state.endDate.trim();
    if (!startDate || !endDate || !site || !substance) {
      return;
    }
    this.props.onParamsSubmit({site: site, substance: substance, startDate: startDate, endDate: endDate});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectStation'){
      this.state.siteIndex = value;
    } else {
      this.state.substanceIndex = value;
    }
  }
  // onChange(event) {
  //   var year = event.format("YYYY");
  //   var month = event.format("MM");
  //   this.setState({year: year, month: month});
  // }
  onStartChange(e) {
    var startDate = e.format("YYYY-MM-DD");
    this.setState({startDate: startDate});
  }
  onEndChange(e) {
    var endDate = e.format("YYYY-MM-DD");
    this.setState({endDate: endDate});
  }
  startDateChange(e) {
    this.setState({startDate: e.target.value});
  }
  endDateChange(e) {
    this.setState({endDate: e.target.value});
  }
  render() {
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <ChemOptionSelect options={this.props.sites} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" defaultValue="3"/>
        <ChemOptionSelect options={this.props.substances} onUserInput={this.handleOptionSelected} name="selectSubstance" key="selectSubstance" />
        {/*<Datetime 
          locale="ru" 
          timeFormat={false} 
          dateFormat="YYYY-MM" 
          closeOnSelect={true} 
          onChange={this.onChange}
        /> 
        <Datetime 
          name="startDate"
          key="startDate"
          locale="ru" 
          dateFormat="YYYY-MM-DD"
          timeFormat={false} 
          input={false}
          onChange={this.onStartChange}
        />*/}
        <input
          type="text"
          value={this.state.startDate}
          onChange={this.startDateChange}
        />
        {/*<Datetime 
          name="endDate"
          key="endDate"
          locale="ru" 
          timeFormat={false} 
          input={false}
          onChange={this.onEndChange}
        />*/}
        <input
          type="text"
          value={this.state.endDate}
          onChange={this.endDateChange}
        />
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}
class BCTable extends React.Component {
  render() {
    var rows = [];
    var concentrations = this.props.concentrations;
    if (this.props.concentrations['size'] < 100)
      for (var i = 0; i < this.props.concentrations['size']; i++) {
        rows.push(<tr key={i}><td></td><td>{concentrations['calm'][i]}</td><td>{concentrations['north'][i]}</td><td>{concentrations['east'][i]}</td><td>{concentrations['south'][i]}</td><td>{concentrations['west'][i]}</td></tr>);
      }
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th></th>
            <th>Ветер менее 3 м/с</th>
            <th>Ветер северный</th>
            <th>Ветер восточный</th>
            <th>Ветер южный</th>
            <th>Ветер западный</th>
          </tr>
        </thead>
        <tbody>
          {rows}
          <tr>
            <td>Число измерений</td>
            <td>{this.props.concentrations.calm.length}</td>
            <td>{this.props.concentrations.north.length}</td>
            <td>{this.props.concentrations.east.length}</td>
            <td>{this.props.concentrations.south.length}</td>
            <td>{this.props.concentrations.west.length}</td>
          </tr>
          <tr>
            <td>Средняя концентрация за период</td>
            <td>{this.props.concentrations.avg_calm}</td>
            <td>{this.props.concentrations.avg_north}</td>
            <td>{this.props.concentrations.avg_east}</td>
            <td>{this.props.concentrations.avg_south}</td>
            <td>{this.props.concentrations.avg_west}</td>
          </tr> 
          <tr>
            <td>Среднеквадратичное отклонение</td> 
            <td>{this.props.concentrations.standard_deviation_calm}</td>
            <td>{this.props.concentrations.standard_deviation_north}</td>
            <td>{this.props.concentrations.standard_deviation_east}</td>
            <td>{this.props.concentrations.standard_deviation_south}</td>
            <td>{this.props.concentrations.standard_deviation_west}</td>
          </tr>
          <tr>
            <td>Коэффициент вариации</td> 
            <td>{this.props.concentrations.variance_calm}</td>
            <td>{this.props.concentrations.variance_north}</td>
            <td>{this.props.concentrations.variance_east}</td>
            <td>{this.props.concentrations.variance_south}</td>
            <td>{this.props.concentrations.variance_west}</td>
          </tr>
          <tr>
            <td>Функция перехода</td> 
            <td>{this.props.concentrations.transition_function_calm}</td>
            <td>{this.props.concentrations.transition_function_north}</td>
            <td>{this.props.concentrations.transition_function_east}</td>
            <td>{this.props.concentrations.transition_function_south}</td>
            <td>{this.props.concentrations.transition_function_west}</td>
          </tr>
          <tr>
            <td>Концентрация</td> 
            <td>{this.props.concentrations.concentration_calm}</td>
            <td>{this.props.concentrations.concentration_north}</td>
            <td>{this.props.concentrations.concentration_east}</td>
            <td>{this.props.concentrations.concentration_south}</td>
            <td>{this.props.concentrations.concentration_west}</td>
          </tr>
          <tr>
            <td>Фоновая концентрация</td> 
            <td>{this.props.concentrations.background_concentration_calm}</td>
            <td>{this.props.concentrations.background_concentration_north}</td>
            <td>{this.props.concentrations.background_concentration_east}</td>
            <td>{this.props.concentrations.background_concentration_south}</td>
            <td>{this.props.concentrations.background_concentration_west}</td>
          </tr>
        </tbody>
      </table>
    );
  }
}    
class ChemBackgroundConcentrations extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      startDate: this.props.startDate,
      endDate: this.props.endDate,
      site_description: this.props.site_description,
      substance: this.props.substance,
      concentrations: this.props.concentrations,
      substances: this.props.substances,
      sites: this.props.sites
    };
    this.handleParamsSubmit = this.handleParamsSubmit.bind(this);
  }
  
  handleParamsSubmit(params) {
    $.ajax({
      type: 'GET',
      url: "get_chem_bc_data?start_date="+params.startDate+"&end_date="+params.endDate+"&site="+params.site+"&substance="+params.substance
      }).done(function(data) {
        this.setState({
          concentrations: data.concentrations,
          startDate: data.startDate,
          endDate: data.endDate,
          substance: data.substance,
          site_description: data.site_description
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  
  render(){
    return(
      <div>
        За период с {this.state.startDate} по {this.state.endDate}
        <br/>
        {this.state.site_description}
        <br/>
        Вещество {this.state.substance}
        <BCParams sites={this.state.sites} substances={this.state.substances} onParamsSubmit={this.handleParamsSubmit} startDate={this.state.startDate} endDate={this.state.endDate} />
        <BCTable concentrations={this.state.concentrations} />
      </div>
    );
  }
}

export default ChemBackgroundConcentrations;