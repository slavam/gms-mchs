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
      pollutions: this.props.pollutions,
      titles: this.props.titles,
      measure_num: this.props.measure_num,
      max_values: this.props.max_values,
      avg_values: this.props.avg_values
    };
    this.handleUserInput = this.handleUserInput.bind(this);
  }
  
  handleUserInput(filterName, filterRoom) {
    this.setState({
      filterName: filterName,
      filterRoom: filterRoom
    });
  }
  
  render(){
    return(
      <div>
        <SearchBar filterName={this.state.filterName} filterRoom={this.state.filterRoom} onUserInput={this.handleUserInput} />
        <Forma1Table pollutions={this.state.pollutions} titles={this.state.titles} measure_num={this.state.measure_num} max_values={this.state.max_values} avg_values={this.state.avg_values}/>
      </div>
    );
  }
}