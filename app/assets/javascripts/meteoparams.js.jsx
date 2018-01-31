class MeteoParamsForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      year:  this.props.year,
      month: this.props.month,
      stationId: 0,
      stationName: '',
      errors: [] 
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.dateChange = this.dateChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  handleOptionSelected(value){
    let idStation = -1;
    let stationName = '';
    this.props.stations.some(function(s){
      idStation = s.id;
      stationName = s.name;
      return +value == s.code;
    });
    this.setState({stationId: idStation, stationName: stationName});
  }
  dateChange(e) {
    var date = e.target.value;
    var year = date.substr(0,4);
    var month = date.substr(5,2);
    this.setState({year: year, month: month});
  }
  handleSubmit(e) {
    e.preventDefault();
    this.props.onFormSubmit({year: this.state.year, month: this.state.month, stationId: this.state.stationId, stationName: this.state.stationName});
  }
  render() {
    var yearMonth = this.state.year+'-'+this.state.month;
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <input type="month" value={yearMonth} min="2000-01" max="2020-01" onChange={this.dateChange}/>
        <TlgOptionSelect options={this.props.stations} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" defaultValue="0" />
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }  
}
const ParamsRow = ({params}) => {
    return (
      <tr key = {params.id}>
        <td width="100px">{params.date}</td>
        <td>{params.term}</td>
        <td>{params.temperature}</td>
        <td>{params.wind_direction}</td>
        <td>{params.wind_speed_avg}</td>
        <td>{params.weather}</td>
        <td>{params.pressure_at_station_level}</td>
      </tr>
    );
};  
const MeteoParamsTable = ({meteoParams}) => {
  var rows = [];
  meteoParams.forEach((p) => {
    rows.push(<ParamsRow params={p} key={p.id} />);
  });
  return (
    <table className="table table-hover">
      <thead>
        <tr>
          <th>Дата</th>
          <th>Срок</th>
          <th>Температура, °С</th>
          <th>Направление ветра, °</th>
          <th>Скорость ветра, м/с</th>
          <th>Атмосферные явления</th>
          <th>Атмосферное давление, hPa</th>
        </tr>
      </thead>
      <tbody>{rows}</tbody>
    </table>
  );
};

class Meteoparams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      meteoParams: this.props.meteoParams,
      year: this.props.year,
      month: this.props.month,
      stationId: 0,
      stationName: ''
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(data){
    this.state.year = data.year;
    this.state.month = data.month;
    this.state.stationName = data.stationName;
    this.state.stationId = data.stationId;
    let that = this;
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "/synoptic_observations/get_meteoparams?year="+data.year+"&month="+data.month+"&station_id="+data.stationId
      }).done((data) => {
        that.setState({meteoParams: data});
      }).fail((res) => {
        that.setState({errors: ["Проблемы с чтением данных из БД"]});
      }); 
  }

  render(){
    let desiredLink = "/synoptic_observations/get_meteoparams.pdf?year="+this.state.year+"&month="+this.state.month+"&station_id="+this.state.stationId;
    let table = this.state.meteoParams.length > 0 ?
      <div>
        <p>Год: {this.state.year}. Месяц: {this.state.month}. Метеостанция: {this.state.stationName}</p>
        <MeteoParamsTable meteoParams={this.state.meteoParams} />
        <p>Число замеров: {this.state.meteoParams.length}</p>
        <a href={desiredLink}>Распечатать</a>
      </div> : '';
    return(
      <div>
        <h1>Таблица наблюдений за метеопараметрами</h1>
        <h3>Задайте год, месяц и метеостанцию</h3>
        <MeteoParamsForm year={this.state.year} month={this.state.month} stations={this.props.stations} onFormSubmit={this.handleFormSubmit}/>
        {table}
      </div>
    );
  }
}
