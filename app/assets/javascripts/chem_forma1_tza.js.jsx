// import React from "react";
// import Datetime from 'react-datetime';
// require('moment/locale/ru');

class ChemOptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.props.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={op.id} value={op.id}>{op.name}</option>;
        })
      }
    </select>;
  }
}
class Forma1Params extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      // posts: this.props.posts,
      siteIndex: this.props.postId,
      month: this.props.month,
      year: this.props.year
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    // this.onChange = this.onChange.bind(this);
    this.dateChange = this.dateChange.bind(this);
  }
  handleSubmit(e) {
    e.preventDefault();
    var site = this.state.siteIndex;
    var month = this.state.month.trim();
    var year = this.state.year.trim();
    if (!year || !month || !site) {
      return;
    }
    this.props.onParamsSubmit({site: site, month: month, year: year});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectStation'){
      this.state.siteIndex = value;
    }
  }
  dateChange(e) {
    var date = e.target.value;
    var year = date.substr(0,4);
    var month = date.substr(5,2);
    this.setState({year: year, month: month});
  }
  // onChange(event) {
  //   var year = event.format("YYYY");
  //   var month = event.format("MM");
  //   this.setState({year: year, month: month});
  // }
  render() {
    var yearMonth = this.state.year+'-'+this.state.month;
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <table className= "table table-hover">
          <thead>
            <tr>
              <th>Пост</th>
              <th>Период</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <ChemOptionSelect options={this.props.posts} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" defaultValue = {this.state.siteIndex}/>
              </td>
              <td>
                <input type="month" value={yearMonth} min="2000-01" max="2020-01" onChange={this.dateChange}/>
              </td>
            </tr>
          </tbody>
        </table>
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}
class OneMeasurement extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      pollution: this.props.pollution
    };
  }
  render() {
    let nDigits = [];
    nDigits[1] = 2;
    nDigits[2] = 3;
    nDigits[4] = 0;
    nDigits[5] = 2;
    nDigits[6] = 2;
    nDigits[8] = 4;
    nDigits[10] = 3;
    nDigits[19] = 2;
    nDigits[22] = 3;
    var row = [];
    var td1 =  this.props.date.substr(8,2);
    var td2 = this.props.date.substr(11,2);
    this.props.pollution.forEach(function(p) {
      // row.push(<td>{p[1]}</td>);
      row.push(<td key={p[0]}>{p[1] > '' ? Number(p[1]).toFixed(nDigits[p[0]] !== 'undefined'? nDigits[p[0]] : 2) : p[1]}</td>);
    });
    // Object.keys(this.props.pollution).forEach((k) => row.push(<td>{this.props.pollution[k]}</td>));
    return (
      <tr>
        <td key={998}>{td1}</td>
        <td key={999}>{td2}</td>
        {row}
      </tr>
    );
  }
}
class Forma1Table extends React.Component {
  render() {
    var rows = [];
    var ths = [];
    var measure = [];
    var max_values = [];
    var avg_values = [];
    // for (var key in array) {
    //   let value = array[key];
    //   console.log(value);
    // }
    // this.props.pollutions.forEach(function(p) {
    //   rows.push(<OneMeasurement pollution={p} key={p.id} />);
    // });
    Object.keys(this.props.pollutions).forEach((p) => rows.push(<OneMeasurement key={p} pollution={this.props.pollutions[p]} date={p} />));
    Object.keys(this.props.titles).forEach((k) => {ths.push(<th key={k}>{this.props.titles[k]}</th>);
      if(k < 100){
        measure.push(<td key={k}>{this.props.measure_num[k]}</td>);
        max_values.push(<td key={k}>{this.props.max_values[k]}</td>);
        avg_values.push(<td key={k}>{this.props.avg_values[k]}</td>);
      }
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Число</th>
            <th>Срок</th>
            {ths}
          </tr>
        </thead>
        <tbody>
          {rows}
          <tr>
            <td>Число измерений</td>
            <td></td>
            {measure}
          </tr>
          <tr>
            <td>Среднее</td>
            <td></td>
            {avg_values}
          </tr>
          <tr>
            <td>Максимум</td>
            <td></td>
            {max_values}
          </tr>
        </tbody>
      </table>
    );
  }
}
class ChemForma1Tza extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      year: this.props.year,
      month: this.props.month,
      site_description: this.props.site_description,
      substance_num: this.props.substance_num,
      pollutions: this.props.pollutions,
      titles: this.props.titles,
      measure_num: this.props.measure_num,
      max_values: this.props.max_values,
      avg_values: this.props.avg_values
      // sites: this.props.sites
    };
    this.desiredLink = "/measurements/print_forma1_tza.pdf?year="+this.props.year+"&month="+this.props.month+"&post_id="+this.props.postId;
    this.handleParamsSubmit = this.handleParamsSubmit.bind(this);
  }
  
  handleParamsSubmit(params) {
    this.desiredLink = "/measurements/print_forma1_tza.pdf?year="+params.year+"&month="+params.month+"&post_id="+params.site;
    $.ajax({
      type: 'GET',
      url: "get_chem_forma1_tza_data?month="+params.month+"&year="+params.year+"&post_id="+params.site
      }).done(function(data) {
        this.setState({
          pollutions: data.matrix.pollutions,
          postId: data.postId,
          month: data.month,
          year: data.year,
          titles: data.matrix.substance_names,
          measure_num: data.matrix.measure_num,
          max_values: data.matrix.max_values,
          avg_values: data.matrix.avg_values,
          site_description: data.matrix.site_description,
          substance_num: data.matrix.substance_num
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  
  render(){
    return(
      <div>
        <h4>Год {this.state.year} Месяц {this.state.month} Количество примесей {this.state.substance_num} {this.state.site_description} </h4>
        <h3>Задайте параметры расчета</h3>
        <Forma1Params posts={this.props.posts} onParamsSubmit={this.handleParamsSubmit} year={this.state.year} month={this.state.month} postId={this.props.postId}/>
        <Forma1Table pollutions={this.state.pollutions} titles={this.state.titles} measure_num={this.state.measure_num} max_values={this.state.max_values} avg_values={this.state.avg_values}/>
        <br />
        <a href={this.desiredLink}>Распечатать</a>
      </div>
    );
  }
}

// export default ChemForma1Tza;