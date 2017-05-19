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
          return <option key={op.idstation} value={op.idstation}>{op.description}</option>;
        })
      }
    </select>;
  }
}
class Forma1Params extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      sites: this.props.sites,
      siteIndex: 1,
      month: this.props.month,
      year: this.props.year
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
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
  render() {
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
       <ChemOptionSelect options={this.props.sites} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" />
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
    var row = [];
    var td1 =  this.props.date.substr(8,2);
    var td2 = this.props.date.substr(11,2);
    this.props.pollution.forEach(function(p) {
      row.push(<td>{p[1]}</td>);
    });
    // Object.keys(this.props.pollution).forEach((k) => row.push(<td>{this.props.pollution[k]}</td>));
    return (
      <tr>
        <td>{td1}</td>
        <td>{td2}</td>
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
    Object.keys(this.props.pollutions).forEach((p) => rows.push(<OneMeasurement pollution={this.props.pollutions[p]} date={p} />));
    Object.keys(this.props.titles).forEach((k) => {ths.push(<th>{this.props.titles[k]}</th>);
      if(k < 100){
        measure.push(<td>{this.props.measure_num[k]}</td>);
        max_values.push(<td>{this.props.max_values[k]}</td>);
        avg_values.push(<td>{this.props.avg_values[k]}</td>);
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
class ChemForma1 extends React.Component{
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
      avg_values: this.props.avg_values,
      sites: this.props.sites
    };
    this.handleParamsSubmit = this.handleParamsSubmit.bind(this);
  }
  
  handleParamsSubmit(params) {
    $.ajax({
      type: 'GET',
      url: "get_chem_forma1_data?month="+params.month+"&year="+params.year+"&site="+params.site
      }).done(function(data) {
        this.setState({
          pollutions: data.matrix.pollutions,
          sites: data.sites,
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
        Год {this.state.year} Месяц {this.state.month}
        <br/>
        {this.state.site_description}
        <br/>
        Количество примесей {this.state.substance_num}
        <Forma1Params sites={this.state.sites} onParamsSubmit={this.handleParamsSubmit} year={this.state.year} month={this.state.month} />
        <Forma1Table pollutions={this.state.pollutions} titles={this.state.titles} measure_num={this.state.measure_num} max_values={this.state.max_values} avg_values={this.state.avg_values}/>
      </div>
    );
  }
}