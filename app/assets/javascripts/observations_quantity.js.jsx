class SelectCity extends React.Component{
  handleChange(e) {
    e.preventDefault();
    this.props.onCityChange(e.target.value);
  }
  render() {
    return(
      <select className='selectCity' onChange={(event) => this.handleChange(event)}>
        {
          this.props.cities.map((c) => {
            return <option key={c.id} value={c.id} >{c.name}</option>;
          })
        }
      </select>
    );
  }
}
class ObservationsForm extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo,
      cityId: 1
    };
    this.dateFromChange = this.dateFromChange.bind(this);
    this.dateToChange = this.dateToChange.bind(this);
    this.handleCityChange = this.handleCityChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  dateFromChange(e){
    this.setState({dateFrom: e.target.value});
  }
  dateToChange(e){
    this.setState({dateTo: e.target.value});
  }
  handleCityChange(value){
    this.setState({cityId: +value});
  }
  handleSubmit(e) {
    e.preventDefault();
    this.props.onParamsSubmit(this.state.dateFrom, this.state.dateTo, this.state.cityId);
  }
  render(){
    return(
      <form className="observationsForm" onSubmit={this.handleSubmit}>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Дата с</th>
              <th>Дата по</th>
              <th>Город</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input type="date" name="input-date-from" value={this.state.dateFrom} onChange={this.dateFromChange} required="true" autoComplete="on" /></td>
              <td><input type="date" name="input-date-to" value={this.state.dateTo} onChange={this.dateToChange} required="true" autoComplete="on" /></td>
              <td><SelectCity cities={this.props.cities} onCityChange={this.handleCityChange} /></td>
            </tr>
          </tbody>
        </table>
        
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}
const ObservationsTable = ({observations, materials, posts, cityId}) => {
  var rows = [];
  var header = [<th>Вещества</th>];
  posts.forEach((p) => {
    if(p.city_id == cityId)
      header.push(<th>{p.short_name}</th>);
  });
  header.push(<th>Всего</th>);
  materials.forEach((m) => {
    let oData = [];
    var s = 0;
    posts.forEach((p) => {
      if(p.city_id == cityId){
        let key = "["+m.id+", "+p.id+"]";      
        s += isNaN(observations[key]) ? 0 : observations[key];
        oData.push(<td>{observations[key]}</td>);
      }
    });
    rows.push(<tr key={m.id}><td>{m.name}</td>{oData}<td>{s}</td></tr>);
  });
  return (
    <table className="table table-hover">
      <thead>
        <tr>
          {header}
        </tr>
      </thead>
      <tbody>{rows}</tbody>
    </table>
  );
};
class ObservationsQuantity extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      observations: this.props.observations,
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo,
      cityId: this.props.cityId,
      total: this.props.total
    };
    this.calcObservations = this.calcObservations.bind(this);
  }
  calcObservations(dateFrom, dateTo, cityId){
    this.state.dateFrom = dateFrom;
    this.state.dateTo = dateTo;
    this.state.cityId = cityId;
     $.ajax({
      type: 'GET',
      dataType: 'json',
      data: {date_from: dateFrom, date_to: dateTo, city_id: cityId}, 
      url: 'observations_quantity'
      }).done((data) => {
        this.setState({observations: data.observations, total: data.total});
        // alert(this.state.errors[0]);
      }).fail((res) => {
        // that.setState({errors: ["Ошибка записи в базу"]});
      }); 
  }
  render(){
    let desiredLink = "/measurements/observations_quantity.pdf?date_from="+this.state.dateFrom+"&date_to="+this.state.dateTo+"&city_id="+this.state.cityId;
    let city;
    this.props.cities.some((c) => {
      city = c;
      return c.id == +this.state.cityId;
    });
    return(
      <div>
        <h3>Задайте параметры расчета</h3>
        <ObservationsForm dateFrom={this.state.dateFrom} dateTo={this.state.dateTo} cities={this.props.cities} onParamsSubmit={this.calcObservations}/>
        <h3>Отчет о количестве наблюдений выполненных на постах контроля за загрязнением атмосферного воздуха</h3>
        <p>Период времени с {this.state.dateFrom} по {this.state.dateTo}</p>
        <p>Город: {city.name} ({city.code})</p>
        <ObservationsTable observations={this.state.observations} materials={this.props.materials} posts={this.props.posts} cityId={this.state.cityId} />
        <p>Всего по городу: {this.state.total}</p>
        <a href={desiredLink}>Распечатать</a>
      </div>
    );
  }
}